{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    globalConfig = {
      tools = {
        node = "26";
        pnpm = "12";
        python = "latest";
        ruby = "latest";
      };
    };
  };
}
