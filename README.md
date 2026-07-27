# Homelab Infrastructure

This repository contains the infrastructure as code for my homelab.

---

| Hypervisor | OS | Tools | Networking | Automation |
|------------|----|-------|------------|------------|
| Proxmox | Talos Linux, Ubuntu | Terraform, Docker, Kubernetes, Flux | Cloudflare, Traefik, Technitium DNS | GitHub Actions, Renovate |

---

# 📖 Overview

This repository contains the Infrastructure as Code (IaC) configuration for my homelab.

My homelab is split into multiple environments:

- **Cloud VPS** running production-facing Docker services
- **Proxmox** running virtual machines and Kubernetes infrastructure
- **Talos Kubernetes cluster** managed through GitOps
- **GPU-enabled Docker VM** for AI and media workloads
- **Raspberry Pi** providing network infrastructure services

Everything possible is defined as code and deployed through automation.

The long-term goal is to continue moving workloads toward Kubernetes while keeping Docker Compose for workloads where it makes more sense, especially GPU-heavy applications.

---

# ☁️ VPS

**Purpose:** Public-facing production services.

## Reverse Proxy

- Traefik v3
- Cloudflare integration
- Automatic TLS

## Monitoring & Observability

- Grafana
- Prometheus
- Loki
- Grafana Alloy
- Uptime Kuma

## Applications

- Vaultwarden
- Homepage
- Webtrees
- Rackula
- Pterodactyl Panel
- Minecraft Server
- Renovate CE

## Websites / Projects

- Portfolio
- Webber Lights
- Troop711
- Personal blog
- Other hosted applications

---

# 🖥️ Proxmox

Main virtualization platform.

Current workloads:

- Talos Kubernetes cluster
- Docker GPU VM

---

# ☸️ Kubernetes

## Talos Linux

The Kubernetes cluster is built using Talos Linux.

Current stack:

- Talos Linux
- Kubernetes
- Flux CD
- Helm

---

## GitOps Workflow

Infrastructure and applications are deployed through Git.

```
Git Repository
      |
      |
      v
    Flux CD
      |
      |
      v
 Kubernetes Cluster
```

Flux continuously reconciles the cluster state with Git.

---

# 🤖 docker-1 GPU VM

Dedicated compute environment for GPU workloads.

## AI

- Ollama
- Open WebUI

## Photos / Media

- Immich
- Jellyfin

---

# 🍓 Raspberry Pi 5

Dedicated network infrastructure device.

## DNS

- Technitium DNS Server

Used for:

- Internal DNS
- Local service discovery
- Network infrastructure

---

# 📊 Monitoring

The homelab uses the Grafana observability stack.

Components:

| Tool | Purpose |
|------|---------|
| Prometheus | Metrics collection |
| Grafana | Dashboards and visualization |
| Loki | Centralized logging |
| Grafana Alloy | Telemetry collection |
| Uptime Kuma | Availability monitoring |

---

# 🔐 Security

Current security tooling:

- Cloudflare DNS/WAF
- Traefik reverse proxy
- Vaultwarden
- Docker Socket Proxy
- Renovate dependency updates

Planned:

- Wazuh SIEM
- Centralized identity management
- Secrets management improvements
- Additional security monitoring

---

# 📁 Repository Structure

```
homelab/
|
├── docker/
│   |
│   ├── vps/
│   └── docker-1/
|
├── kubernetes/
│   |
│   ├── clusters/
│   ├── infrastructure/
│   └── apps/
|
├── terraform/

```

---

# 🖥️ Hardware

## Current Infrastructure

| Device | Hardware | Purpose |
|--------|----------|---------|
| Proxmox Host | AMD Ryzen, 64GB DDR5 RAM | Virtualization |
| docker-1 VM | GPU passthrough VM | AI and media workloads |
| Raspberry Pi 5 | 8GB RAM | DNS infrastructure |
| NAS | 20TB storage | Data storage and backups |

---

# 🎯 Goals

The goal is to build a realistic production-style environment while maintaining reliability and documentation.
