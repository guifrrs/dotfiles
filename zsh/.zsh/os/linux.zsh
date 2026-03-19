if command -v id >/dev/null 2>&1; then
  export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"
fi
