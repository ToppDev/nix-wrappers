{...}: {
  flake.wrappers.helix = {...}: {
    settings = {
      theme = "ayu_dark_plus";
    };

    themes = {
      ayu_dark_plus = {
        inherits = "ayu_dark";

        "attribute" = "red";
        "variable.parameter" = {
          fg = "#eba0ac";
          modifiers = ["italic"];
        };
        "variable.builtin" = "red";
        "punctuation.special" = "#89dceb";
        "keyword.control.conditional" = "orange";
        "function.macro" = "#f4a6f7";

        "ui.linenr" = "#5c6773";
        "ui.linenr.selected" = "#9da3ab";
        "ui.cursorline.primary" = {"bg" = "#252933";};
        "ui.popup".bg = "#16203b";
        "ui.menu".bg = "#1f2430";

        "markup.heading.1" = "#cc3300";
        "markup.heading.2" = "#ff9966";
        "markup.heading.3" = "#EED202";
        "markup.heading.4" = "#a6e3a1";
        "markup.heading.5" = "#74c7ec";
        "markup.heading.6" = "#b4befe";
        "markup.list.checked" = "green";
        "markup.raw" = "green";
        "markup.raw.block" = "green";

        "ui.virtual.inlay-hint" = {
          fg = "#87898c";
          bg = "#121b24";
        };
        "ui.cursor.match" = {
          fg = "dark_gray";
          bg = "#b4befe";
        };
        "ui.cursor" = {
          fg = "black";
          bg = "yellow";
        };
        "warning" = {
          fg = "#ffed29";
          modifiers = ["bold"];
        };
        "hint" = {
          fg = "#99f291";
          modifiers = ["bold"];
        };
      };
    };
  };
}
