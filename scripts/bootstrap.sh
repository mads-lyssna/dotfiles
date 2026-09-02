#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

[[ "$(uname -s)" == "Darwin" ]] || fail "bootstrap only supports macOS."
[[ "$(uname -m)" == "arm64" ]] || fail "bootstrap requires an Apple Silicon Mac."
[[ "$(id -un)" == "madeleine.ostoja" && "$HOME" == "/Users/madeleine.ostoja" ]] || \
  fail "bootstrap is configured for user madeleine.ostoja at /Users/madeleine.ostoja."
[[ "$REPO_DIR" == "$HOME/dotfiles" ]] || fail "clone this repository to $HOME/dotfiles first."
xcode-select -p >/dev/null 2>&1 || \
  fail "install and complete the Xcode Command Line Tools first: xcode-select --install"

BREW_BIN="/opt/homebrew/bin/brew"
if [[ ! -x "$BREW_BIN" ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
[[ -x "$BREW_BIN" ]] || fail "Homebrew installation did not provide $BREW_BIN."
eval "$("$BREW_BIN" shellenv)"

if ! command -v nix >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
fi
NIX_PROFILE_SCRIPT="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
[[ -r "$NIX_PROFILE_SCRIPT" ]] || fail "Nix installation did not provide $NIX_PROFILE_SCRIPT."
# shellcheck source=/dev/null
source "$NIX_PROFILE_SCRIPT"

nix flake update --flake "$REPO_DIR"
backup_extension="home-manager-backup-$(date +%Y%m%d%H%M%S)"
nix run --no-update-lock-file "path:$REPO_DIR#home-manager" -- \
  --no-update-lock-file switch --flake "path:$REPO_DIR" -b "$backup_extension"
export PATH="$HOME/.nix-profile/bin:$PATH"

"$HOME/.nix-profile/bin/sys" sync --apps || \
  fail "application sync failed; confirm the Brewfile applications are available."
(
  cd "$HOME"
  mise install
)
"$REPO_DIR/scripts/defaults.sh"

git -C "$REPO_DIR" config core.hooksPath .githooks
chmod +x "$REPO_DIR/.githooks/pre-commit"

if ! gh auth status --hostname github.com >/dev/null 2>&1; then
  gh auth login --hostname github.com --git-protocol https --web
fi
gh auth setup-git

printf 'Bootstrap complete. Finish the GUI setup in README.md.\n'
