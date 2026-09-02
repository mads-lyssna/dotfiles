let
  mkBinding = key: modifiers: action: when: {
    inherit
      key
      modifiers
      action
      when
      ;
  };
in
{
  programs.fresh-editor = {
    enable = true;
    defaultEditor = true;
    settings = {
      version = 1;
      theme = "theme.json";
      check_for_updates = false;
      self_update = false;
      keybindings = [
        (mkBinding "s" [ "super" ] "save" "normal")
        (mkBinding "z" [ "super" ] "undo" "normal")
        (mkBinding "z" [
          "super"
          "shift"
        ] "redo" "normal")
        (mkBinding "Left" [
          "super"
          "shift"
        ] "select_line_start" "normal")
        (mkBinding "Right" [
          "super"
          "shift"
        ] "select_line_end" "normal")
        (mkBinding "Up" [
          "super"
          "shift"
        ] "select_document_start" "normal")
        (mkBinding "Down" [
          "super"
          "shift"
        ] "select_document_end" "normal")
        (mkBinding "o" [ "ctrl" ] "quick_open_files" "global")
        (mkBinding "o" [
          "ctrl"
          "alt"
        ] "open" "normal")
        (mkBinding ";" [ "ctrl" ] "quick_open_buffers" "global")
        (mkBinding "b" [ "alt" ] "move_word_left" "global")
        (mkBinding "f" [ "alt" ] "move_word_end" "global")
        (mkBinding "Left" [ "alt" ] "move_word_left" "global")
        (mkBinding "Right" [ "alt" ] "move_word_end" "global")
      ];
      editor = {
        line_wrap = false;
        show_menu_bar = false;
        menu_bar_mnemonics = false;
        show_tab_bar = false;
        show_vertical_scrollbar = false;
        show_tilde = false;
        nerd_font_icons = true;
        cursor_style = "steady_bar";
        indentation_guide = "all";
        indentation_guide_glyph = "╎";
        completion_popup_auto_show = true;
        diagnostics_inline_text = true;
        restore_previous_session = false;
        auto_create_empty_buffer_on_last_buffer_close = false;
      };
      file_explorer.auto_open_on_last_buffer_close = false;
      plugins = {
        dashboard.enabled = false;
        devcontainer.enabled = false;
        git_explorer.enabled = false;
        "k8s-workspace".enabled = false;
        orchestrator.enabled = false;
      };
    };
  };

  xdg.configFile."fresh/themes/theme.json".source = ../configs/fresh/theme.json;
}
