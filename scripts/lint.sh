#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

nix shell "nixpkgs#nixfmt" -c nixfmt --check flake.nix home.nix modules/*.nix
nix eval --no-write-lock-file "path:$REPO_DIR#homeConfigurations.\"madeleine.ostoja\".activationPackage.drvPath" >/dev/null

shell_files=()
while IFS= read -r file; do
  bash -n "$file"
  shell_files+=("$file")
done < <(fd -H -t f -e sh scripts; printf '%s\n' bin/sys .githooks/pre-commit)
nix shell "nixpkgs#shellcheck" -c shellcheck "${shell_files[@]}"

while IFS= read -r file; do
  jq empty "$file"
done < <(fd -H -t f -e json configs)

while IFS= read -r file; do
  plutil -lint "$file"
done < <(fd -H -t f -e plist .)

if git grep -InE '[[:blank:]]+$' -- .; then
  printf 'Error: trailing whitespace found.\n' >&2
  exit 1
fi
