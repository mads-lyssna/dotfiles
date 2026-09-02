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
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  sysCommand = pkgs.writeShellApplication {
    name = "sys";
    runtimeInputs = [ pkgs.gum ];
    text = ''
      exec "$HOME/dotfiles/bin/sys" "$@"
    '';
  };
in
{
  home.username = baseNameOf homeDirectory;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  services.home-manager.autoExpire = lib.mkIf isDarwin {
    enable = true;
    timestamp = "-30 days";
    frequency = "weekly";
    store.cleanup = true;
  };

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "macchiato";
    accent = "mauve";
  };

  # Modules
  imports = [
    ./modules/editor.nix
    ./modules/git.nix
    ./modules/mise.nix
    ./modules/shell.nix
    ./modules/ssh.nix
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
      sysCommand

      # Git
      lazygit

      # Work Services
      awscli2
      buildkite-cli
      heroku
    ]
    ++ lib.optionals isDarwin [
      nixfmt
      devcontainer
    ];

  home.sessionVariables.COLORTERM = "truecolor";

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
    ".config/otty".source = mkLink "configs/otty";
    ".hammerspoon/init.lua".source = mkLink "configs/hammerspoon.lua";
  };
}
