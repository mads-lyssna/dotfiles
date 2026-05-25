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

  # Modules
  imports = [
    ./modules/zsh.nix
  ];

  # Packages
  home.packages =
    with pkgs;
    [
      # Shell
      starship

      # CLI tools
      bat
      eza
      ripgrep
      fd
      fzf
      dust
      hyperfine

      # Git
      git
      delta
      gh
      worktrunk

      # Other
      ctx7

      # Work Services
      awscli2
      buildkite-cli
      heroku
    ]
    ++ lib.optionals isDarwin [
      nixfmt
      mise
      pnpm
      devcontainer
      claude-code
    ];

  # Environment
  home.sessionVariables = {
    EDITOR = "zed --wait";
    VISUAL = "zed --wait";
    PNPM_HOME = pnpmHome;
    AWS_PROFILE = "development";
    AWS_REGION = "us-east-1";
  };

  # PNPM setup
  home.sessionPath = [
    pnpmHome
    "${pnpmHome}/bin"
  ];

  # Ensure global pnpm packages are installed
  home.activation.pnpmGlobals = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PNPM_HOME="${pnpmHome}"
    export PATH="${pkgs.nodejs}/bin:${pkgs.pnpm}/bin:$PNPM_HOME:$PATH"
    for pkg in ${lib.escapeShellArgs pnpmGlobals}; do
      if ! ${pkgs.pnpm}/bin/pnpm ls -g --depth=0 2>/dev/null | grep -q "$pkg"; then
        run ${pkgs.pnpm}/bin/pnpm add -g "$pkg"
      fi
    done
  '';

  # Config files
  home.file = {
    # Git
    ".config/git/config".source = mkLink "configs/git/config";
    ".config/git/ignore".source = mkLink "configs/git/ignore";

    # Pi
    ".pi/agent/settings.json".source = mkLink "configs/pi/settings.json";
    ".pi/agent/models.json".source = mkLink "configs/pi/models.json";
    ".pi/agent/keybindings.json".source = mkLink "configs/pi/keybindings.json";
    ".pi/agent/themes/theme.json".source = mkLink "configs/pi/theme.json";
    ".pi/agent/extensions".source = mkLink "configs/pi/extensions";
    ".pi/agent" = {
      source = "${agents}";
      recursive = true;
    };

    # Zed
    ".config/zed/settings.json".source = mkLink "configs/zed/settings.json";
    ".config/zed/keymap.json".source = mkLink "configs/zed/keymap.json";

    # Claude
    ".claude/settings.json".source = mkLink "configs/claude/settings.json";
    ".claude/CLAUDE.md".source = "${agents}/AGENTS.md";
    ".claude/skills" = {
      source = "${agents}/skills";
      recursive = true;
    };

  }
  // lib.optionalAttrs isDarwin {
    ".ssh/config".source = mkLink "configs/ssh";
    ".config/ghostty/config".source = mkLink "configs/ghostty";
    ".hammerspoon/init.lua".source = mkLink "configs/hammerspoon.lua";
  };
}
