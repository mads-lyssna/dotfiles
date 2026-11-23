{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com".User = "git";
      "*" = {
        IdentityAgent = "~/.1password/agent.sock";
        ServerAliveInterval = 60;
      };
    };
  };
}
