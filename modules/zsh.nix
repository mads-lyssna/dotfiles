{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      save = 10000;
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
    };

    shellAliases = {
      # Tool swaps
      cat = "bat --paging=never";
      less = "bat";
      ls = "eza --group-directories-first";
      ll = "eza -la --group-directories-first --git";
      tree = "eza --tree --level=2";

      # Convenience
      c = "clear";
      rmf = "rm -rf";
      pn = "pnpm";
      sb = "supabase";
      cc = "claude";
      dc = "devcontainer";

      # Git
      g = "git";
      gs = "git status";
      ga = "git add";
      gaa = "git add --all";
      gc = "git commit -m";
      gaac = "git add --all && git commit -m";
      grm = "git rm";
      gb = "git branch";
      gab = "git checkout -b";
      gcb = "git checkout";
      grmb = "git branch -D";
      grmtag = "git tag -d";
      gdis = "git checkout --";
      glog = "git log --graph";
      gpull = "git pull";
      grpull = "git fetch && git rebase";
      gpush = "git push";
      gpushf = "git push --force-with-lease --force-if-includes";
      greset = "git reset HEAD~1";
      grecommit = "git commit --amend -C HEAD";
      gcp = "git cherry-pick";
      gr = "git rebase";
      gf = "git fetch";
      lg = "lazygit";

      # Shortcuts
      nixsync = "cd ~/dotfiles && nix flake update agents && home-manager switch --flake .";
      brewsync = "brew bundle install --cleanup --force --zap --file=~/dotfiles/Brewfile";
      sysupdate = "~/dotfiles/scripts/update.sh";
      devclean = "docker system prune --volumes";
    };

    initContent = ''
      setopt AUTO_CD INTERACTIVE_COMMENTS EXTENDED_GLOB NO_BEEP
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      export SSH_AUTH_SOCK=~/.1password/agent.sock
      if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      git_status.disabled = true;
      nodejs.symbol = "󰎙 ";
      ruby.symbol = " ";
      docker_context.symbol = " ";
      aws = {
        format = "on [$symbol$profile]($style) ";
        symbol = "󰸏 ";
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    globalConfig = {
      tools = {
        node = "lts";
        ruby = "4.0";
      };
      settings = {
        ruby.compile = false;
        idiomatic_version_file_enable_tools = [ "ruby" ];
      };
    };
  };

}
