#!/usr/bin/env bash
# Base devcontainer installer. Installs Nix (single-user), runs home-manager,
# installs Marvin. Run as the vscode user inside the container.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"

run() {
  local desc="$1"; shift
  local output
  if output=$("$@" 2>&1); then
    echo "✓ $desc"
  else
    echo "✗ $desc"
    echo "$output"
    return 1
  fi
}

# 1. Install Nix if missing
if ! command -v nix >/dev/null 2>&1; then
  echo "→ Installing Nix (single-user)"
  sh <(curl -L https://nixos.org/nix/install) --no-daemon
fi

# Source Nix into current shell
if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# 2. Run home-manager
echo "→ Running home-manager switch for vscode"
nix run home-manager/master -- \
  switch --flake "${DOTFILES}#vscode" \
  --extra-experimental-features 'nix-command flakes'

# 3. Install Marvin (needs pnpm on PATH from home-manager)
export PATH="$HOME/.nix-profile/bin:$PATH"
if command -v pnpm >/dev/null 2>&1; then
  run "marvin installed" pnpm add -g github:madeleineostoja/marvin
else
  echo "✗ pnpm not on PATH after home-manager; skipping marvin"
fi

echo "✓ install complete"
