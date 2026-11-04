#!/usr/bin/env bash
# Validates every docker/<host>/<service> compose project without real secrets:
# creates an empty .env where missing and fills `${VAR:?...}` (required)
# variables with a placeholder. Optional variables use their defaults.
set -uo pipefail

failed=0
for file in docker/*/*/docker-compose.y*ml; do
  dir=$(dirname "$file")
  created_env=0
  if [ ! -e "$dir/.env" ]; then
    : > "$dir/.env"
    created_env=1
  fi

  required=$(grep -hoE '\$\{[A-Za-z_][A-Za-z0-9_]*:\?' "$dir"/*.y*ml \
    | sed -E 's/^\$\{//; s/:\?$//' | sort -u)
  placeholders=()
  for var in $required; do placeholders+=("$var=placeholder"); done

  if output=$(cd "$dir" && env ${placeholders[@]+"${placeholders[@]}"} docker compose config --quiet 2>&1); then
    echo "ok    $dir"
  else
    echo "FAIL  $dir"
    echo "$output" | grep -v 'level=warning' | sed 's/^/      /'
    failed=1
  fi

  [ "$created_env" = 1 ] && rm -f "$dir/.env"
done

exit "$failed"
