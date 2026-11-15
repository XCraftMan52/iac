#!/bin/bash
# Container entrypoint for FPP 10.x in Docker.
#
# FPP normally relies on systemd for two things the container doesn't have:
#   1. D-Bus + Avahi (fppd's mDNS/MultiSync discovery). Upstream runDocker.sh does
#      this itself after FalconChristmas/fpp@8140f77 (not in 10.4 yet), but it
#      doesn't clear stale files left behind by `docker restart`.
#   2. PipeWire. FPP 10 retired the direct-ALSA backend and starts
#      fpp-pipewire / fpp-wireplumber / fpp-pipewire-pulse with systemctl, which
#      silently fails in a container -> no audio. We run them here instead, with
#      the same environment as FPP's systemd units (etc/systemd/fpp-*.service).
#
# The PipeWire env vars that clients (fppd) need are set in docker-compose.yml so
# every process in the container inherits them.

# ---------------------------------------------------------------- D-Bus + Avahi
rm -f /var/run/dbus/pid /run/dbus/pid /run/dbus/system_bus_socket /var/run/avahi-daemon/pid
mkdir -p /run/dbus
dbus-daemon --system --fork
avahi-daemon --daemonize

# --------------------------------------------------------------------- PipeWire
pw_log() { echo "pipewire-supervisor: $*"; }

# Restart a daemon whenever it exits (systemd's Restart=on-failure, RestartSec=3).
supervise() {
    local name=$1; shift
    while true; do
        "$@" >>"/tmp/$name.log" 2>&1
        pw_log "$name exited ($?), restarting in 3s"
        sleep 3
    done
}

start_pipewire() {
    # fppinit (run by runDocker.sh below) writes FPP's PipeWire config on start;
    # wait for it so PipeWire comes up with FPP's sinks, not a bare default.
    for _ in $(seq 1 60); do
        [ -f /etc/pipewire/pipewire.conf.d/95-fpp-alsa-sink.conf ] && break
        sleep 1
    done

    mkdir -p "$PIPEWIRE_RUNTIME_DIR" "$PULSE_RUNTIME_PATH" /var/lib/pipewire-fpp/pulse
    chown root:audio "$PULSE_RUNTIME_PATH" && chmod 0775 "$PULSE_RUNTIME_PATH"

    supervise pipewire env PIPEWIRE_STATE_DIR=/var/lib/pipewire-fpp /usr/bin/pipewire &
    for _ in $(seq 1 20); do [ -S "$PIPEWIRE_RUNTIME_DIR/pipewire-0" ] && break; sleep 0.5; done

    supervise wireplumber env DBUS_SESSION_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket \
        PIPEWIRE_STATE_DIR=/var/lib/pipewire-fpp /usr/bin/wireplumber &
    supervise pipewire-pulse env PULSE_STATE_PATH=/var/lib/pipewire-fpp/pulse \
        PIPEWIRE_STATE_DIR=/var/lib/pipewire-fpp /usr/bin/pipewire-pulse &

    # Wait until WirePlumber has the graph up.
    for _ in $(seq 1 30); do wpctl status >/dev/null 2>&1 && break; sleep 1; done
    pw_log "PipeWire is up"

    # runDocker.sh starts fppd right after fppinit, i.e. before PipeWire was
    # running. Restart it once so it attaches to PipeWire (same as a manual test).
    for _ in $(seq 1 60); do pgrep -x fppd >/dev/null && break; sleep 1; done
    pw_log "restarting fppd so it attaches to PipeWire"
    /opt/fpp/scripts/fppd_stop
    sleep 2
    /opt/fpp/scripts/fppd_start
}

start_pipewire &

# ------------------------------------------------------------------------ FPP
exec /opt/fpp/Docker/runDocker.sh
