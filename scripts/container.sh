#!/usr/bin/env bash
# Base devcontainer installer. Installs Nix, runs home-manager.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"

# 1. Install Nix if missing
if ! command -v nix >/dev/null 2>&1; then
  echo "→ Installing Nix"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install linux --init none --no-confirm
fi

# Source Nix into current shell
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
elif [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# Start Nix daemon if not running (required with --init none)
if ! pgrep -f nix-daemon >/dev/null 2>&1; then
  sudo /nix/var/nix/profiles/default/bin/nix-daemon &
  sleep 2
fi

# 2. Fetch prebuilt Nix cache if available
CACHE_URL="https://github.com/madeleineostoja/dotfiles/releases/download/devcontainers-cache/devcontainers-nix-cache.tar.gz"
mkdir -p /tmp/nix-cache
if curl -fsSL "$CACHE_URL" | tar -xz -C /tmp/nix-cache; then
  export NIX_CONFIG="extra-substituters = file:///tmp/nix-cache
require-sigs = false"
else
  echo "  cache unavailable, falling back to upstream substituters"
fi

# 3. Run home-manager
echo "→ Running home-manager switch for vscode"
nix run home-manager/master -- switch -b backup --flake "${DOTFILES}#vscode"

echo "✓ install complete"
