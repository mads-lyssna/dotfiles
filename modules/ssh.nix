{ lib, pkgs, ... }:

lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    # OrbStack's generated host must be included before any Host blocks.
    includes = [ "~/.orbstack/ssh/config" ];
    settings = {
      "github.com".User = "git";
      "*" = {
        IdentityAgent = "~/.1password/agent.sock";
        ServerAliveInterval = 60;
      };
    };
  };
}
