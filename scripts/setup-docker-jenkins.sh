#!/usr/bin/env bash
set -euo pipefail

# This script installs Docker Engine on a Linux host and grants the 'jenkins'
# user permission to run Docker commands without sudo.
#
# Supported distros: Ubuntu/Debian, RHEL/CentOS/Rocky/Alma (using dnf/yum)
# Requires: root privileges

if [[ ${EUID} -ne 0 ]]; then
  echo "This script must be run as root (use sudo)." >&2
  exit 1
fi

JENKINS_USER="jenkins"

detect_pkg_mgr() {
  if command -v apt-get >/dev/null 2>&1; then
    echo apt
  elif command -v dnf >/dev/null 2>&1; then
    echo dnf
  elif command -v yum >/dev/null 2>&1; then
    echo yum
  else
    echo unknown
  fi
}

install_docker_apt() {
  apt-get update -y
  apt-get install -y ca-certificates curl gnupg lsb-release
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  . /etc/os-release
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" > /etc/apt/sources.list.d/docker.list
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl enable --now docker
}

install_docker_dnf() {
  dnf -y install dnf-plugins-core
  dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl enable --now docker
}

install_docker_yum() {
  yum install -y yum-utils
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum install -y docker-ce docker-ce-cli containerd.io
  systemctl enable --now docker
}

ensure_user_in_docker_group() {
  groupadd -f docker
  usermod -aG docker "${JENKINS_USER}" || true
}

restart_services() {
  systemctl restart docker || true
  if systemctl is-active --quiet jenkins; then
    systemctl restart jenkins || true
  fi
}

verify() {
  echo "Waiting for Docker daemon..." >&2
  for i in {1..60}; do
    if docker info >/dev/null 2>&1; then break; fi
    sleep 2
  done
  docker version || true
  id "${JENKINS_USER}" || true
  echo "If permissions don't take effect, log out and back in or reboot." >&2
}

main() {
  pkg=$(detect_pkg_mgr)
  case "$pkg" in
    apt) install_docker_apt ;;
    dnf) install_docker_dnf ;;
    yum) install_docker_yum ;;
    *) echo "Unsupported distro. Install Docker manually." >&2; exit 2 ;;
  esac

  ensure_user_in_docker_group
  restart_services
  verify
}

main "$@"


