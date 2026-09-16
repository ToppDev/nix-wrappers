{...}: {
  flake.wrappers.yazi = {
    wlib,
    pkgs,
    lib,
    config,
    ...
  }: let
    drag-n-drop-target = pkgs.writeShellApplication {
      name = "drag-n-drop-target";
      runtimeInputs = [pkgs.dragon-drop pkgs.zenity];
      text = builtins.readFile ./drag-n-drop.sh;
    };
    # mkPlugin = {
    #   name,
    #   version ? "2026-06-22",
    #   src ?
    #     pkgs.fetchFromGitHub {
    #       owner = "yazi-rs";
    #       repo = "plugins";
    #       rev = "38efe09c270162f1b0dfb6020e021a5b64bdc735";
    #       sha256 = "sha256-QkjXl8lGeqFgL2FGTs63xW0/hbZEpIaBCWnkdCgcv5s=";
    #     },
    # }:
    #   pkgs.stdenv.mkDerivation {
    #     pname = "yazi-plugin-${name}";
    #     version = version;
    #     src = src;
    #     phases = ["installPhase"];
    #     installPhase = ''mkdir -p $out; [ -d $src/${name}.yazi ] && cp -r $src/${name}.yazi/* $out || cp -r $src/* $out; ${pkgs.findutils}/bin/find $out -xtype l -delete '';
    #   };
    # mkCustomPlugin = {
    #   name,
    #   text ? null,
    #   src ? null,
    # }:
    #   pkgs.stdenv.mkDerivation {
    #     pname = "yazi-plugin-${name}";
    #     version = "2026-06-22";
    #     phases = ["installPhase"];
    #     src =
    #       if src != null
    #       then src
    #       else pkgs.writeText "main.lua" text;
    #     installPhase = ''mkdir -p $out; cp -r $src $out/main.lua'';
    #   };
  in {
    imports = [wlib.wrapperModules.yazi];

    # Replaces `shellWrapperName = "y"`
    aliases = ["y"];

    # Called by the openers and previewers below. Note pkgs.yaziPlugins.ouch is
    # only the Lua plugin — the `ouch` binary the "Extract here" opener runs is
    # a separate package, so archive preview worked while extracting did not.
    runtimePkgs = with pkgs; [
      ouch
      xdg-utils # xdg-open
      direnv
      tmux
    ];

    plugins = {
      ouch = pkgs.yaziPlugins.ouch;
      starship = pkgs.yaziPlugins.starship;
      mediainfo = pkgs.yaziPlugins.mediainfo;
      piper = pkgs.yaziPlugins.piper;
      smart-paste = pkgs.yaziPlugins.smart-paste;
      chmod = pkgs.yaziPlugins.chmod;
      full-border = pkgs.yaziPlugins.full-border;
      git = pkgs.yaziPlugins.git;
      mount = pkgs.yaziPlugins.mount;
      # chmod = mkPlugin {name = "chmod";};
      # full-border = mkPlugin {name = "full-border";};
      # git = mkPlugin {name = "git";};
      # mount = mkPlugin {name = "mount";};
      # starship = mkPlugin {
      #   name = "starship";
      #   version = "2025-06-01";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "Rolv-Apneseth";
      #     repo = "starship.yazi";
      #     rev = "6a0f3f788971b155cbc7cec47f6f11aebbc148c9";
      #     sha256 = "sha256-q1G0Y4JAuAv8+zckImzbRvozVn489qiYVGFQbdCxC98=";
      #   };
      # };
    };

    flavors = let
      mkFlavor = {
        name,
        src ?
          pkgs.fetchFromGitHub {
            owner = "yazi-rs";
            repo = "flavors";
            rev = "0f9204bc948c8313963f5c9d571a82edc201f8aa";
            sha256 = "sha256-qWNArjWuxWL+rOjLzyIniW5hJgWiAWTCgXmMXJpaWZE=";
          },
      }:
        pkgs.stdenv.mkDerivation {
          pname = "yazi-${name}";
          version = "2026-05-31";
          src = src;
          phases = ["installPhase"];
          installPhase = ''
            mkdir -p $out
            [ -d $src/${name}.yazi ] && cp $src/${name}.yazi/* $out || cp $src/* $out
          '';
        };
    in {
      catppuccin-mocha = mkFlavor {name = "catppuccin-mocha";};
      # ayu-dark = mkFlavor {
      #   name = "ayu-dark";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "kmlupreti";
      #     repo = "ayu-dark.yazi";
      #     rev = "5412a78219a646c2c3192ae810da95676a218c45";
      #     sha256 = "sha256-rWgQ/PqJ4L+nUx1dc7qQfXGGQBzg00d1KexVkNVG6JI=";
      #   };
      # };
    };

    settings = {
      yazi = {
        mgr = {
          ratio = [2 4 3];
          sort_by = "natural";
          title_format = "{cwd}";
        };
        preview = {
          max_width = 1200;
          max_height = 1000;
        };
        opener = {
          edit = [
            {
              run = ''[ -n "$TMUX" ] && [ -d "$1" ] && ya emit enter && direnv exec "$1" ''${EDITOR} "$@" && ya emit leave || direnv exec . ''${EDITOR} "$@"'';
              desc = "Edit";
              block = true;
              for = "unix";
            }
          ];
          play = [
            {
              run = ''${pkgs.vlc}/bin/vlc "$@"'';
              desc = "VLC";
              orphan = true;
              for = "unix";
            }
          ];
          open = [
            {
              run = ''xdg-open "$@"'';
              desc = "Open";
              orphan = true;
            }
          ];
          extract = [
            {
              run = ''ouch d -y "$@"'';
              desc = "Extract here";
              for = "unix";
            }
          ];
          image = [
            {
              run = ''${pkgs.qimgv}/bin/qimgv "$@"'';
              desc = "Image Viewer";
              for = "unix";
            }
          ];
          csv = [
            {
              run = ''tmux popup -T"csvlens" -h90% -w90% -E "tmux kill-session -t \"csvlens\"; tmux new -s \"csvlens\" '${pkgs.csvlens}/bin/csvlens \"$1\"'"'';
              orphan = true;
              desc = "Csvlens";
              for = "unix";
            }
          ];
        };
        open = {
          prepend_rules = [
            {
              url = "*.csv";
              use = ["csv" "edit" "reveal"];
            }
            {
              mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
              use = ["extract" "open" "reveal"];
            }
            {
              url = "*.zip";
              use = ["extract" "open" "reveal"];
            }
            {
              mime = "image/*";
              use = ["image" "open" "reveal"];
            }
          ];
        };
        plugin = {
          prepend_previewers = let
            mkPreviewer = ext: previewer: {
              url = "*." + ext;
              run = previewer;
            };
            rich-preview = ''piper -- PYTHONWARNINGS="ignore" ${pkgs.rich-cli}/bin/rich -j --left --guides --line-numbers --force-terminal "$1"'';
          in [
            (mkPreviewer "md" rich-preview)
            (mkPreviewer "csv" rich-preview)
            (mkPreviewer "rst" rich-preview)
            (mkPreviewer "ipynb" rich-preview)
            (mkPreviewer "json" rich-preview)
            {
              mime = "{audio,video,image}/*";
              run = "mediainfo";
            }
            {
              mime = "application/subrip";
              run = "mediainfo";
            }
            {
              mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
              run = "ouch";
            }
            (mkPreviewer "zip" "ouch")
          ];
          prepend_preloaders = [
            {
              mime = "{audio,video,image}/*";
              run = "mediainfo";
            }
            {
              mime = "application/subrip";
              run = "mediainfo";
            }
          ];
          prepend_fetchers = [
            {
              id = "git";
              url = "*";
              run = "git";
              group = "git";
            }
            {
              id = "git";
              url = "*/";
              run = "git";
              group = "git";
            }
          ];
        };
      };

      theme = {
        flavor = {
          dark = "catppuccin-mocha";
          light = "catppuccin-mocha";
        };
        spot = {
          title.fg = "green";
        };
      };

      keymap = {
        mgr.prepend_keymap = [
          {
            on = ["<C-n>"];
            run = ''shell -- [ -z "$2" ] && ${pkgs.dragon-drop}/bin/dragon-drop -x -i -T "$1" || ${pkgs.dragon-drop}/bin/dragon-drop -x -i -A -T "$@"'';
            desc = "Drag and drop source";
          }
          {
            on = ["<C-t>"];
            run = ''shell -- ${drag-n-drop-target}/bin/drag-n-drop-target "$1"'';
            desc = "Drag and drop target";
          }
          {
            on = ["<C-o>"];
            run = ''shell -- [ -d "$1" ] && ya emit cd "$1" || ya emit cd "$(dirname "$1")"'';
            desc = "Directory";
          }
          {
            on = ["A"];
            run = "toggle_all --state=on";
            desc = "Select all files";
          }
          {
            on = ["C"];
            run = "plugin ouch 7z";
            desc = "Compress with ouch";
          }
          {
            on = ["c" "m"];
            run = "plugin chmod";
            desc = "Chmod on selected files";
          }
          {
            on = "M";
            run = "plugin mount";
            desc = "Mount manager";
          }
          {
            on = "!";
            run = ''shell --block -- [ -d "$1" ] && cd "$1"; "$SHELL"'';
            desc = "Open shell here";
          }
          {
            on = "p";
            run = "plugin smart-paste";
            desc = "Paste into the hovered directory or CWD";
          }
          {
            on = "<C-p>";
            run = "paste";
            desc = "Paste yanked files";
          }
          {
            on = "R";
            run = "bulk_rename";
            desc = "Bulk rename file";
          }
          {
            on = "y";
            run = [''shell -- echo "$@" | ${pkgs.xclip}/bin/xclip -i -selection clipboard -t text/uri-list'' "yank"];
          }
          {
            on = ["g" "e"];
            run = "arrow \"bot\"";
            desc = "Goto bottom";
          }
          {
            on = ["g" "c"];
            run = ["noop"];
          }
        ];
      };
    };

    # The Yazi wrapper module generates all its toml files in a temporary directory
    # accessible via `${config.generatedConfig.placeholder}`
    buildCommand.addInitLua = {
      # This ensures our hook runs immediately after the plugins are linked
      after = ["makePluginsAndFlavors"];
      data =
        # bash
        ''
          # copy the init.lua file directly into the generated config directory
          cp ${./init.lua} ${lib.escapeShellArg "${config.generatedConfig.placeholder}/init.lua"}
        '';
    };
  };
}
