# Dotfiles

Workstation configuration for `madeleine.ostoja`, primarily targeting an Apple Silicon Mac with a smaller Home Manager profile for Linux devcontainers.

## Stack

- **Nix + Home Manager** — CLI tools, shell configuration, managed links, and user services
- **Homebrew** — GUI applications, fonts, and platform-specific CLIs
- **mise** — language runtimes and global ecosystem CLIs
- **Worktrunk** — worktree creation and personal worktree hooks

## First-time setup

Install the Xcode Command Line Tools, wait for installation to finish, then clone over HTTPS and run the bootstrap:

```bash
xcode-select --install
/usr/bin/git clone https://github.com/mads-lyssna/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/bootstrap.sh
```

`bootstrap.sh` requires macOS on Apple Silicon, user `madeleine.ostoja`, `/Users/madeleine.ostoja`, a completed CLT installation, and this repository at `~/dotfiles`. It installs Homebrew and Determinate Nix when absent, creates a local lockfile from current inputs, applies Home Manager, reconciles the Brewfile, installs mise tools, applies macOS defaults, enables the repository hook, and starts GitHub HTTPS authentication.

Home Manager conflicts are saved with a timestamped `home-manager-backup-*` suffix. Homebrew environment setup is managed in the Home Manager Zsh profile, so bootstrap does not modify `~/.zprofile`.

## Complete after bootstrap

- **1Password** — enable its SSH agent; Home Manager configures SSH to use `~/.1password/agent.sock`.
- **Hyperkey** — grant Accessibility permission and enable “Caps Lock as Hyper”.
- **Hammerspoon** — grant Accessibility permission and enable Launch at Login.
- **Rectangle** — grant Accessibility permission and enable Launch at Login.
- **BetterDisplay** — grant the requested permissions and enable Launch at Login as needed.
- **Pearcleaner** — enable Sentinel for occasional orphan cleanup.
- **Time Machine** — add a backup disk and exclude `~/Code`, `~/.cache`, `/nix`, `/nix/store`, and `~/Library/Caches`.

Create three Spaces in Mission Control, then configure these shortcuts in System Settings → Keyboard → Keyboard Shortcuts:

| Action | Binding | Section |
| --- | --- | --- |
| Switch to Desktop 1–3 | Hyper+1–3 | Mission Control |

Pi asks before trusting projects and Zed does not trust all worktrees. Before using Worktrunk, open `~/Code` as the parent directory in each application and trust it once; worktrees below it then share that trust boundary.

## Maintenance

### Weekly

Home Manager expires generations older than 30 days and garbage-collects unreachable user-store paths weekly.

### Quarterly

```bash
sys update
```

This updates and reconciles Homebrew applications on macOS, updates all Nix inputs, applies Home Manager, and installs and upgrades configured mise tools.

`flake.lock` is local and ignored. Bootstrap creates it with current inputs, ordinary rebuilds retain those local pins, and `sys update` advances them without creating repository changes.

### On demand

```bash
sys cleanup
```

This removes stale Homebrew artifacts on macOS and then optimises the Nix store.

### Command boundaries

- `sys sync` updates Nix everywhere and also reconciles applications on macOS.
- `sys sync --apps` reconciles only the Brewfile and is available on macOS.
- `sys sync --nix` updates the `agents` input, applies Home Manager, and installs configured mise tools.
- `sys update` performs the complete quarterly update.
- `sys cleanup` reclaims disk space without updating dependencies.

The legacy `brewsync`, `nixsync`, and `sysupdate` aliases map to the corresponding `sys` commands.

To roll back Home Manager without updating inputs:

```bash
home-manager switch --rollback
```

## Common operations

**Add a native CLI tool:** add it to `home.packages` in `home.nix`, or use its Home Manager module in the relevant file under `modules/`, then run `sys sync --nix`.

**Add a global runtime or ecosystem CLI:** edit `programs.mise.globalConfig` in `modules/mise.nix`, then run `sys sync --nix`.

**Add a GUI application:** add a cask to `Brewfile`, then run `sys sync --apps`.

**Add a configuration file:** create it under `configs/`, add an out-of-store link in `home.nix`, then run `sys sync --nix`. Changes to linked files are live immediately, but Home Manager rollback cannot undo those edits.

**Try a tool ephemerally:**

```bash
nix shell nixpkgs#whatever
```

**Inspect Home Manager changes:**

```bash
home-manager generations
nix profile diff-closures --profile ~/.local/state/nix/profiles/home-manager
```

## Ownership boundaries

Native workstation tools such as `bat`, `ripgrep`, `fd`, and `fzf` belong in Nix. Node, pnpm, Python, Ruby, and personal npm CLIs belong in mise. Repository build, test, and runtime tooling belongs in that repository.

Databases, queues, and other stateful development services are not host installs. Repositories own them through platform simulators, disposable remote resources, or project-scoped OrbStack containers. Worktrunk creates worktrees and runs personal setup hooks; repositories must still work with a plain `git worktree add`.

## Linting and recovery

The repository hook calls the same checks available manually:

```bash
./scripts/lint.sh
```

It checks Nix formatting and evaluation, Bash syntax and ShellCheck, strict JSON, plist validity, and trailing whitespace. Bootstrap configures `core.hooksPath` to `.githooks`.

Useful verification and recovery commands:

```bash
nix eval --no-write-lock-file "path:$HOME/dotfiles#homeConfigurations.\"madeleine.ostoja\".activationPackage.drvPath"
brew bundle check --file=~/dotfiles/Brewfile
home-manager switch --rollback
```
