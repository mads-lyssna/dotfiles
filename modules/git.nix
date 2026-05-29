{ ... }:

{
  programs.gh.enable = true;
  programs.git = {
    enable = true;
    ignores = [
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "Icon?"
      "._*"
      "*.swp"
      "*.swo"
      "*~"
    ];
    settings = {
      user = {
        name = "Madi Ostoja";
        email = "madeleine.ostoja@lyssna.com";
      };

      init.defaultBranch = "main";

      core = {
        pager = "delta";
        editor = "zed --wait";
      };

      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      pull.ff = "only";
      push = {
        default = "current";
        autoSetupRemote = true;
      };
      fetch.prune = true;
      rerere.enabled = true;
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
    };
  };
}
