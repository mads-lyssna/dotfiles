#!/usr/bin/env bash
set -uo pipefail

REPO_DIR="${HOME}/dotfiles"

start_time=$(date +%s)
echo "🔄 System update — $(date '+%Y-%m-%d %H:%M:%S')"
echo

# --- Homebrew ---
echo "▶ brew update..."
brew update || { echo "❌ brew update failed"; exit 1; }

echo
echo "▶ Outdated:"
brew outdated || true

echo
echo "▶ brew upgrade..."
brew upgrade || echo "⚠️  some brew upgrades failed (continuing)"

echo
echo "▶ Reconciling Brewfile..."
brew bundle install --cleanup --force --zap --file="${REPO_DIR}/Brewfile" \
  || echo "⚠️  Brewfile reconcile had issues"

echo
echo "▶ brew cleanup..."
brew cleanup --prune=all

# --- Nix ---
if command -v nix >/dev/null 2>&1; then
  echo
  echo "▶ nix flake update..."
  (cd "$REPO_DIR" && nix flake update) \
    || { echo "❌ nix flake update failed"; exit 1; }

  echo
  echo "▶ home-manager switch..."
  (cd "$REPO_DIR" && home-manager switch --flake .) \
    || { echo "❌ home-manager switch failed — try 'home-manager switch --rollback'"; exit 1; }

  # GC happens via launch agent; not duplicated here
fi

# --- mise ---
if command -v mise >/dev/null 2>&1; then
  echo
  echo "▶ mise plugin update..."
  mise plugin update || echo "⚠️  mise plugin update had issues"
fi

# --- pnpm globals ---
if command -v pnpm >/dev/null 2>&1; then
  echo
  echo "▶ pnpm update -g --latest..."
  pnpm update -g --latest || echo "⚠️  pnpm global update had issues"
fi

end_time=$(date +%s)
duration=$((end_time - start_time))
echo
echo "✅ Done in ${duration}s."
echo
echo "Review and commit:"
echo "  cd ~/dotfiles && git diff flake.lock"
echo "If anything broke: home-manager switch --rollback"