#!/usr/bin/env bash
# Work devcontainer installer. Switches dotfiles to the `work` branch,
# then delegates to the base container installer.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"

cd "$DOTFILES"
git fetch origin work
git checkout work
git pull --ff-only origin work

exec "$DOTFILES/scripts/container.sh"
