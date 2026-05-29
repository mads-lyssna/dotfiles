{ lib, ... }:

{
  home.sessionVariables = {
    GH_COLOR_LABELS = "1";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    RG_COLORS = lib.concatStringsSep ":" [
      "path:fg:0x8a,0xad,0xf4"
      "line:fg:0xa6,0xda,0x95"
      "column:fg:0xee,0xd4,0x9f"
      "match:fg:0xed,0x87,0x96"
      "match:style:bold"
    ];
  };

  catppuccin = {
    enable = true;
    flavor = "macchiato";
    zsh-syntax-highlighting.enable = false;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      highlight = "fg=#6e738d";
    };
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
      z = "zed";
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
      grmrb = "git push origin --delete";
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

      # Shortcuts
      nixsync = "cd ~/dotfiles && nix flake update && home-manager switch --flake .";
      brewsync = "brew bundle install --cleanup --force --zap --file=~/dotfiles/Brewfile";
      sysupdate = "~/dotfiles/scripts/update.sh";
    };

    initContent = ''
      setopt AUTO_CD INTERACTIVE_COMMENTS EXTENDED_GLOB NO_BEEP
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      character = {
        success_symbol = "[❯](peach)";
        error_symbol = "[❯](red)";
      };
      directory = {
        style = "bold lavender";
        read_only = " 󰌾";
      };
      git_branch = {
        style = "bold mauve";
        symbol = " ";
      };
      git_commit.tag_symbol = "  ";
      git_status.disabled = true;
      package.symbol = "󰏗 ";
      nodejs.symbol = "󰎙 ";
      python.symbol = " ";
      ruby.symbol = " ";
      nix_shell.symbol = " ";
      docker_context.symbol = " ";
      container.symbol = " ";
      aws = {
        symbol = "󰸏 ";
        format = "on [$symbol($profile )]($style)";
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bat = {
    enable = true;
    config.pager = "less -FR";
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.lazygit = {
    enable = true;
    package = null;
    enableZshIntegration = true;
  };

  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    globalConfig = {
      tools = {
        node = "lts";
        python = "3.12";
        ruby = "4.0.4";
      };
    };
  };
}
