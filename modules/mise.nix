{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    globalConfig = {
      settings.minimum_release_age = "0s";
      tools = {
        node = "26";
        pnpm = "12";
        python = "latest";
        ruby = "latest";
        "npm:@earendil-works/pi-coding-agent" = "latest";
      };
    };
  };
}
