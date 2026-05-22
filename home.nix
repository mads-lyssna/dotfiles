{
  config,
  pkgs,
  lib,
  homeDirectory,
  ...
}:

let
  dotfiles = "${homeDirectory}/dotfiles";
  mkLink = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
  isDarwin = pkgs.stdenv.isDarwin;
  pnpmHome =
    if isDarwin then "${homeDirectory}/Library/pnpm" else "${homeDirectory}/.local/share/pnpm";
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

      # Work Services
      awscli2
      buildkite-cli
      sentry-cli 
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
    EDITOR = "code --wait";
    VISUAL = "code --wait";
    PNPM_HOME = pnpmHome;
    AWS_PROFILE = "development";
    AWS_REGION = "us-east-1";
  };

  # PNPM setup — pnpm 11 stores binaries in $PNPM_HOME/bin, but still checks
  # that $PNPM_HOME itself is on PATH, so include both.
  home.sessionPath = [
    pnpmHome
    "${pnpmHome}/bin"
  ];

  # Config files
  home.file = {
    ".config/git/config".source = mkLink "configs/git/config";
    ".config/git/ignore".source = mkLink "configs/git/ignore";

    # Claude
    ".claude/CLAUDE.md".source = mkLink "configs/claude/CLAUDE.md";
    ".claude/settings.json".source = mkLink "configs/claude/settings.json";
    ".claude/statusline-command.sh".source = mkLink "configs/claude/statusline-command.sh";
    ".claude/skills" = {
      source = mkLink "configs/claude/skills";
      recursive = true;
    };
  }
  // lib.optionalAttrs isDarwin {
    ".ssh/config".source = mkLink "configs/ssh";
    ".config/ghostty/config".source = mkLink "configs/ghostty";
    ".hammerspoon/init.lua".source = mkLink "configs/hammerspoon.lua";
  };
}
