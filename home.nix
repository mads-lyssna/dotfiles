{
  config,
  pkgs,
  lib,
  homeDirectory,
  agents,
  ...
}:

let
  dotfiles = "${homeDirectory}/dotfiles";
  mkLink = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
  isDarwin = pkgs.stdenv.isDarwin;
  pnpmHome =
    if isDarwin then "${homeDirectory}/Library/pnpm" else "${homeDirectory}/.local/share/pnpm";

  # Global pnpm packages, if a nix package isn't available or updated enough
  pnpmGlobals = [
    "sentry"
    "@earendil-works/pi-coding-agent"
  ];
in
{
  home.username = baseNameOf homeDirectory;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  catppuccin = {
    flavor = "macchiato";
    accent = "mauve";
  };

  # Modules
  imports = [
    ./modules/git.nix
    ./modules/shell.nix
  ];

  # Packages
  home.packages =
    with pkgs;
    [
      # Shell
      starship

      # CLI tools
      bat
      ripgrep
      fd
      fzf
      dust
      mprocs

      # Git
      lazygit

      # Work Services
      awscli2
      buildkite-cli
      heroku
    ]
    ++ lib.optionals isDarwin [
      nixfmt
      mise
      pnpm_10
      devcontainer
    ];

  # Environment
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
    COLORTERM = "truecolor";
    PNPM_HOME = pnpmHome;
  };

  # PNPM setup
  home.sessionPath = [
    pnpmHome
  ];

  # Ensure global pnpm packages are installed
  home.activation.pnpmGlobals = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PNPM_HOME="${pnpmHome}"
    export PATH="${pkgs.nodejs}/bin:${pkgs.pnpm_10}/bin:$PNPM_HOME:$PATH"
    for pkg in ${lib.escapeShellArgs pnpmGlobals}; do
      if ! ${pkgs.pnpm_10}/bin/pnpm ls -g --depth=0 2>/dev/null | grep -q "$pkg"; then
        run ${pkgs.pnpm_10}/bin/pnpm add -g --ignore-scripts "$pkg"
      fi
    done
  '';

  # Config files
  home.file = {
    # CLI
    ".config/worktrunk/config.toml".source = mkLink "configs/worktrunk.toml";

    # Pi
    ".pi/agent" = {
      source = "${agents}";
      recursive = true;
    };
    ".pi/agent/settings.json".source = mkLink "configs/pi/settings.json";
    ".pi/agent/keybindings.json".source = mkLink "configs/pi/keybindings.json";
    ".pi/agent/pipkin/config.json".source = mkLink "configs/pi/pipkin.json";

    # Zed
    ".config/zed/settings.json".source = mkLink "configs/zed/settings.json";
    ".config/zed/keymap.json".source = mkLink "configs/zed/keymap.json";
  }
  // lib.optionalAttrs isDarwin {
    ".ssh/config".source = mkLink "configs/ssh";
    ".config/otty".source = mkLink "configs/otty";
    ".hammerspoon/init.lua".source = mkLink "configs/hammerspoon.lua";
  };
}
