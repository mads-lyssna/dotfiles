# Dotfiles

My personal workstation configuration, running on a Macbook Pro

## Stack

- **Nix + home-manager** — packages, shell, shell-integrated tools
- **Homebrew** — GUI casks and fonts (`Brewfile`)
- **mise** — per-project language runtimes

## Repo layout

```
dotfiles/
├── flake.nix                        # Nix inputs and outputs
├── flake.lock                       # Pinned versions
├── home.nix                         # home-manager config
├── Brewfile                         # GUI casks and fonts
├── modules/zsh.nix                  # Shell + integrated tools
├── config/*                         # Standalone dotfiles
├── launchd/com.user.nix-gc.plist    # Launch agent for GC
├── scripts
  ├── defaults.sh                    # macOS defaults
  ├── update.sh                      # Manual update script
  ├── nix-gc.sh                      # Background garbage collection for nix
```

## First-time setup

```bash
# 1. Xcode CLT
xcode-select --install

# 2. SSH key
ssh-keygen -t ed25519 -C "your-personal-email@example.com" -f ~/.ssh/id_ed25519
# Add ~/.ssh/id_ed25519.pub to GitHub: Settings → SSH and GPG keys

# 3. Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# 4. Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 5. Dotfiles
git clone https://github.com/mads-lyssna/dotfiles.git
chflags hidden dotfiles

# 6. Bootstrap`
cd ~/dotfiles
nix run home-manager/master -- switch --flake .
brew bundle install --file=./Brewfile
./scripts/defaults.sh
launchctl load ~/dotfiles/launchd/com.user.nix-gc.plist
```

## Manual GUI setup

After bootstrap, complete these once.

### Hyperkey

- Grant accessibility permissions
- Enable "Caps Lock as Hyper"

### Keyboard shortcuts

Open Hammerspoon, grant accessibility permissions, and enable "Launch at Login" in the menu bar icon. Binds in `configs/hammerspoon.lua` will load automatically.

System Settings → Keyboard → Keyboard Shortcuts:

| Action                | Binding   | Section         |
| --------------------- | --------- | --------------- |
| Switch to Desktop 1–3 | Hyper+1–3 | Mission Control |

Create the three Spaces first via Mission Control (3-finger swipe up, click +).

### Other apps

- **Rectangle** — accessibility permissions, launch on login
- **MonitorControl** — accessibility permissions, launch on login
- **Time Machine** — add backup disk, exclude `~/Code`, `~/.cache`, `/nix`, `/nix/store`, `~/Library/Caches`

## Maintenance

### Continuous (automatic)

MacOS security patches, browsers, Zed, casks with built-in updaters all self-update.

### Weekly (automatic via launch agent)

`scripts/nix-gc.sh` runs via launchd, throttled to roughly weekly. Logs to `/tmp/nix-gc.log`.

### Quarterly (manual)

```bash
sysupdate
```

Runs `scripts/update.sh`: brew update/upgrade, Brewfile reconcile with `--zap`, `nix flake update`, `nixsync`, mise plugin update.

After:

```bash
cd ~/dotfiles
git diff flake.lock
git commit -am "chore: quarterly update"
git push
```

If broken: `nixsync --rollback`.

### Occasional

- **Pearcleaner** — orphan-files scan after removing apps
- **DaisyDisk** — investigating disk-full situations

## Common operations

**Add a CLI tool (no shell integration):**
Edit `home.nix` → `home.packages`. Run `nixsync`.

**Add a CLI tool (with shell integration):**
Edit `modules/zsh.nix` → add `programs.<tool>` block with `enableZshIntegration = true`. Run `nixsync`.

**Add a GUI app:**
Edit `Brewfile` → `cask "name"`. Run `brew bundle install`.

**Add a config file:**
Create file at `configs/<tool>` in repo. Add to `home.nix`:

```nix
"{config path}".source = mkLink "configs/<tool>";
```

Run `nixsync`.

**Edit existing config:**

- Non-shell (gitconfig, ghostty, ssh, claude): edit in repo, immediately live.
- Shell (zsh, starship, mise, atuin, fzf): edit `modules/zsh.nix`, run `nixsync`.

**Roll back:**

```bash
nixsync --rollback
```

**Try a tool ephemerally:**

```bash
nix shell nixpkgs#whatever
```

**Inspect generated shell config:**

```bash
cat ~/.zshrc
cat ~/.zshenv
```

**Per-project runtime versions:**

```bash
cd /path/to/project
mise use node@20
```

**Manual GC (bypass throttle):**

```bash
rm -f ~/.local/state/nix-gc-last-run
~/Code/dotfiles/nix-gc.sh
```

**Disable launch agent:**

```bash
launchctl unload ~/Code/dotfiles/launchd/com.user.nix-gc.plist
```

## Runbooks

### Disable Time Machine drive auto-mount on work

```bash
# 1. Plug drive in once on work laptop
diskutil info "TimeMachineDriveName"   # find Volume UUID

# 2. Edit /etc/fstab
sudo vifs

# 3. Add line:
UUID=YOUR-UUID-HERE none apfs rw,noauto # Time Machine

# 4. Save (Esc, :wq, Enter)
```

To reverse: edit `/etc/fstab`, remove the line.

### Removing an app properly

```bash
# 1. Edit Brewfile, remove cask line, commit
# 2. Reconcile (uninstalls + zaps cask-defined associated files)
brew bundle install --cleanup --force --zap --file=~/dotfiles/Brewfile

# 3. Optional: open Pearcleaner → "Remaining Files" for orphans
```

### Inspecting what changed in a recent home-manager sync

```bash
home-manager generations
nix profile diff-closures --profile ~/.local/state/nix/profiles/home-manager
```
