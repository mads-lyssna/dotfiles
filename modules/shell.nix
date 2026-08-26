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
    autoEnable = true;
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
      dcu = "devcontainer up && devcontainer exec zsh";
      piup = "pi update && pi update --extensions";

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
      gbclean = "git branch --merged main | grep -v '^[* ]*main$' | xargs -r git branch -d";

      # Shortcuts
      dockerprune = "docker container prune -f && docker volume prune -af && docker network prune -f";
      nixsync = "nix flake update agents --flake ~/dotfiles && home-manager switch --flake ~/dotfiles";
      brewsync = "brew bundle install --cleanup --force --zap --file=~/dotfiles/Brewfile";
      sysupdate = "~/dotfiles/scripts/update.sh";
      awsagents = "aws sso login --profile agents --use-device-code";
    };

    initContent = ''
      setopt AUTO_CD INTERACTIVE_COMMENTS EXTENDED_GLOB NO_BEEP
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      dockerorphans() {
        local id name config configs
        local all_durable_configs_missing has_durable_config

        docker ps -aq --filter label=com.docker.compose.project.config_files | while read -r id; do
          configs=$(docker inspect -f '{{ index .Config.Labels "com.docker.compose.project.config_files" }}' "$id")
          all_durable_configs_missing=true
          has_durable_config=false

          while read -r config; do
            [[ "$config" == */devcontainercli/docker-compose/* ]] && continue
            has_durable_config=true
            [[ -e "$config" ]] || continue
            all_durable_configs_missing=false
            break
          done < <(print -r -- "$configs" | tr ',' '\n')

          [[ "$has_durable_config" == true && "$all_durable_configs_missing" == true ]] || continue

          name=$(docker inspect -f '{{ .Name }}' "$id")
          print "Removing orphaned Compose container ''${name#/}"
          docker rm -f "$id"
        done

        docker container prune -f && docker volume prune -af && docker network prune -f
      }
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "$directory$git_branch$nix_shell$container$cmd_duration$status$line_break$character";
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
        truncation_length = 32;
        truncation_symbol = "…";
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

  programs.helix = {
    enable = true;
    settings = {
      editor = {
        line-number = "relative";
        cursorline = true;
        bufferline = "multiple";
        color-modes = true;
        popup-border = "all";
        end-of-line-diagnostics = "hint";
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
        indent-guides = {
          render = true;
          character = "╎";
          skip-levels = 1;
        };
        inline-diagnostics.cursor-line = "warning";
      };
      keys = {
        normal = {
          "Cmd-s" = ":write";
          "Cmd-/" = "toggle_comments";
          "Cmd-." = "code_action";
          "C-a" = "goto_line_start";
          "C-e" = "goto_line_end";
          "A-b" = "move_prev_word_start";
          "A-f" = "move_next_word_start";
          F2 = "rename_symbol";
          F12 = "goto_definition";
          "S-F12" = "goto_reference";
        };
        insert = {
          "Cmd-s" = ":write";
          "Cmd-/" = "toggle_comments";
          "Cmd-." = "code_action";
          "C-a" = "goto_line_start";
          "C-e" = "goto_line_end";
          "A-b" = "move_prev_word_start";
          "A-f" = "move_next_word_start";
          F2 = "rename_symbol";
          F12 = "goto_definition";
          "S-F12" = "goto_reference";
        };
        select = {
          "Cmd-s" = ":write";
          "Cmd-/" = "toggle_comments";
          "Cmd-." = "code_action";
          "C-a" = "goto_line_start";
          "C-e" = "goto_line_end";
          "A-b" = "move_prev_word_start";
          "A-f" = "move_next_word_start";
          F2 = "rename_symbol";
          F12 = "goto_definition";
          "S-F12" = "goto_reference";
        };
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

  programs.worktrunk = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    globalConfig = {
      tools = {
        node = "latest";
        python = "latest";
        ruby = "latest";
      };
    };
  };
}
