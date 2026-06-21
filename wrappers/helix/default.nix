{...}: {
  flake.wrappers.helix = {wlib, ...}: {
    imports = [wlib.wrapperModules.helix];

    settings = {
      editor = {
        scrolloff = 8;
        line-number = "relative";
        cursorline = true;
        idle-timeout = 5;
        completion-timeout = 5;
        completion-replace = false;
        rulers = [101];
        color-modes = true;
        text-width = 100;
        end-of-line-diagnostics = "hint";
        inline-diagnostics.cursor-line = "hint";

        statusline = {
          right = ["diagnostics" "selections" "register" "file-type" "position" "file-encoding"];
        };

        lsp = {
          display-inlay-hints = true;
        };

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        whitespace = {
          render = {
            space = "none";
            nbsp = "all";
            nnbsp = "all";
            tab = "all";
            newline = "none";
          };
        };

        indent-guides = {
          render = true;
          character = "╎";
          skip-levels = 1;
        };

        soft-wrap = {
          enable = true;
          max-wrap = 25;
        };
      };
    };
  };
}
