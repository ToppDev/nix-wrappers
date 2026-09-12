{self, ...}: {
  flake.wrappers.helix = {
    pkgs,
    lib,
    ...
  }: let
    selfpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
    recursiveMerge = attrList: let
      f = with lib;
        attrPath:
          zipAttrsWith (
            n: values:
              if tail values == []
              then head values
              else if all isList values
              then unique (concatLists values)
              else if all isAttrs values
              then f (attrPath ++ [n]) values
              else last values
          );
    in
      f [] attrList;

    integration-lazygit = [
      ":write-all"
      ":insert-output env XDG_CONFIG_HOME=$HOME/.config ${lib.getExe selfpkgs.lazygit} >/dev/tty"
      ":reload-all"
      ":redraw"
    ];

    integration-yazi = scope: let
      # $XDG_RUNTIME_DIR rather than a fixed name in /tmp: that directory is
      # 0700 and per user, so on a shared machine the first user to create the
      # old path owned it and everyone else's `rm -f` then failed. Expanded by
      # the shell each of these commands runs in. Written without braces on
      # purpose — a `}` inside `%sh{...}` below would end the block early.
      tmpfile = "$XDG_RUNTIME_DIR/hx-yazi-chooser";
    in [
      ":sh rm -f ${tmpfile}"
      ":insert-output env XDG_CONFIG_HOME=$HOME/.config ${lib.getExe selfpkgs.yazi} '${scope}' --chooser-file=${tmpfile}"
      ":insert-output echo \"\x1b[?1049h\" > /dev/tty"
      ":open %sh{${pkgs.coreutils}/bin/cat ${tmpfile}}"
      ":redraw"
      ":set mouse false"
      ":set mouse true"
    ];

    integration-scooter = let
      scooter-wrapper = pkgs.writeShellApplication {
        name = "scooter-wrapper";
        text = ''
          export XDG_CONFIG_HOME="$HOME/.config"

          input=$(cat)
          if [ -z "$input" ] || [ ''${#input} -eq 1 ] || [[ "$input" == *$'\n'* ]]; then
            ${lib.getExe selfpkgs.scooter} --no-stdin
          else
            ${lib.getExe selfpkgs.scooter} --no-stdin --search-text "$input" --replace-text "$input"
          fi
        '';
      };
    in [
      ":write-all"
      ":pipe-to ${scooter-wrapper}/bin/scooter-wrapper >/dev/tty"
      ":reload-all"
      ":redraw"
    ];
  in {
    settings.keys = let
      mkViewKeybindings = key: dir: let
        keyUpper =
          if builtins.stringLength key == 1
          then lib.toUpper key
          else "S-${key}";
        mkKeybinds = key: dir: {
          C-w."${key}" = "jump_view_${dir}";
          C-w."C-${key}" = "jump_view_${dir}";
          space.w."C-${key}" = "jump_view_${dir}";
          space.w."${key}" = "jump_view_${dir}";
          C-w."${keyUpper}" = "swap_view_${dir}";
          space.w."${keyUpper}" = "swap_view_${dir}";
        };
      in {
        normal = mkKeybinds key dir;
        select = mkKeybinds key dir;
      };
      mkVerMoveKeybindings = key: dir: let
        mkKeybinds = mode: {
          "${key}" = "${mode}_visual_line_${dir}";
          g."${key}" = "${mode}_line_${dir}";
          z."${key}" = "scroll_${dir}";
          Z."${key}" = "scroll_${dir}";
        };
      in {
        normal = mkKeybinds "move";
        select = mkKeybinds "extend";
      };
      mkHorMoveKeybindings = key: dir: DIR: let
        mkKeybinds = mode: {
          "${key}" = "${mode}_char_${dir}";
          g."${key}" = "goto_line_${DIR}";
        };
      in {
        normal = mkKeybinds "move";
        select = mkKeybinds "extend";
      };
      mkSearchKeybindings = key: let
        mkKeybinds = txt: {
          h = "${txt}search_next";
          H = "${txt}search_prev";
          z.h = "search_next";
          Z.h = "search_next";
          z.H = "search_prev";
          Z.H = "search_prev";
          A-h = "select_next_sibling";
        };
      in {
        normal =
          mkKeybinds ""
          // {
            g.h = "goto_next_buffer";
            C-w.h.v = "vsplit_new";
            C-w.h.C-v = "vsplit_new";
            C-w.h.s = "hsplit_new";
            C-w.h.C-s = "hsplit_new";
          };
        select = mkKeybinds "extend_";
      };
      normal_select = {
        C-r = integration-scooter;
      };
    in
      recursiveMerge [
        (mkHorMoveKeybindings "l" "left" "start")
        (mkViewKeybindings "l" "left")
        (mkVerMoveKeybindings "n" "down")
        (mkViewKeybindings "n" "down")
        (mkVerMoveKeybindings "del" "up")
        (mkViewKeybindings "del" "up")
        (mkHorMoveKeybindings "j" "right" "end")
        (mkViewKeybindings "j" "right")
        (mkSearchKeybindings "h")
        {
          normal =
            {
              C-u = ["page_cursor_half_up" "align_view_center"];
              C-d = ["page_cursor_half_down" "align_view_center"];
              C-e = ["scroll_down" "move_line_down"];
              C-y = ["scroll_up" "move_line_up"];
              C-z = "increment";
              "C-up" = ["jump_view_up"];
              "C-down" = ["jump_view_down"];
              "C-left" = ["jump_view_left"];
              "C-right" = ["jump_view_right"];
              C-x = ":reset-diff-change";
              g.O = ["open_above" "delete_word_backward"];
              g.o = ["open_below" "delete_word_backward"];
              space.x = ":write-quit-all";
              space.X = ":write-quit-all!";
              "}" = ["goto_next_paragraph"];
              "{" = ["goto_prev_paragraph"];
              space.C-d = "@<space>D%severity ERROR ";
              x = "select_line_below";
              X = "select_line_above";
              C-g = integration-lazygit;
              space.e = integration-yazi "%{buffer_name}";
              space.E = integration-yazi "%{workspace_directory}";
            }
            // normal_select;
          select = {} // normal_select;
        }
      ];
  };
}
