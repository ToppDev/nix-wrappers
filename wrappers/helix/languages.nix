{...}: {
  flake.wrappers.helix = {
    pkgs,
    lib,
    config,
    ...
  }: {
    # Using makeWrapperArgs natively within the wrapper
    drv.makeWrapperArgs = [
      "--suffix"
      "PATH"
      ":"
      (lib.makeBinPath (with pkgs; [
        lldb
        uwu-colors
        bibtex-tidy
        texlab
        simple-completion-language-server
        ltex-ls-plus
        harper
        marksman
        alejandra
        nixd
        taplo
        typstyle
        awk-language-server
        bash-language-server
        clang-tools
        cmake-language-server
        dockerfile-language-server
        vscode-langservers-extracted
        java-language-server
        typescript-language-server
        jq-lsp
        lua-language-server
        openscad-lsp
        rust-analyzer
        lemminx
        yaml-language-server
        zig
        zls
        tinymist
      ]))
    ];

    languages = {
      language-server = {
        harper-ls = {
          command = "harper-ls";
          args = ["--stdio"];
        };
        scls = {
          command = "simple-completion-language-server";
          config = {
            max_completion_items = 100;
            feature_words = true;
            feature_snippets = true;
            snippets_first = true;
            snippets_inline_by_word_tail = false;
            feature_unicode_input = false;
            feature_paths = false;
            feature_citations = false;
          };
        };
        ltex-ls-plus = {
          config.ltex = {
            language = "en-US";
            additionalRules.enablePickyRules = false;
            dictionary."en-US" = [
              "builtin"
            ];
          };
        };
        nixd = {
          config.nixd = {
            formatting.command = ["alejandra"];
            nixpkgs.expr = ''import (builtins.getFlake (builtins.getEnv "HOME" + "/.nix-config")).inputs.nixpkgs { }'';
            options = {
              nixos.expr = ''(builtins.getFlake (builtins.getEnv "HOME" + "/.nix-config")).nixosConfigurations.default.options'';
            };
          };
        };
        rust-analyzer.config.check = {command = "clippy";};
        uwu-colors = {command = "${pkgs.uwu-colors}/bin/uwu_colors";};
        pylsp = {
          command = "pylsp";
          config.pylsp.plugins = {
            pycodestyle.enabled = false;
            pyflakes.enabled = false;
            flake8.enabled = false;
            mccabe.enabled = false;
            jedi_completion = {
              enabled = true;
              include_params = true;
            };
            jedi_hover.enabled = true;
            jedi_signature_help.enabled = true;
          };
        };
      };
      language = [
        {
          name = "git-commit";
          language-servers = ["scls"];
        }
        {
          name = "latex";
          language-servers = ["texlab" "ltex-ls-plus" "harper-ls" "scls" "uwu-colors"];
        }
        {
          name = "markdown";
          comment-tokens = ["-" "+" "*" "- [ ]" ">"];
          language-servers = ["marksman" "ltex-ls-plus" "harper-ls" "scls" "uwu-colors"];
        }
        {
          name = "nix";
          formatter.command = "alejandra";
          auto-format = true;
          language-servers = ["nixd" "scls" "uwu-colors"];
        }
        {
          name = "cpp";
          formatter.command = "clang-format";
          auto-format = true;
        }
        {
          name = "python";
          formatter = {
            command = "ruff";
            args = ["format" "-"];
          };
          auto-format = true;
          language-servers = [
            {
              name = "pylsp";
              except-features = ["format" "diagnostics"];
            }
            {
              name = "basedpyright";
              except-features = ["format" "hover" "completion" "goto-definition" "signature-help"];
            }
            "ruff"
          ];
        }
        {
          name = "stub";
          scope = "text.stub";
          file-types = [];
          shebangs = [];
          roots = [];
          auto-format = false;
          language-servers = ["scls" "uwu-colors"];
        }
        {
          name = "toml";
          formatter = {
            command = "taplo";
            args = ["fmt" "-"];
          };
          auto-format = true;
        }
        {
          name = "typst";
          language-servers = ["tinymist" "ltex-ls-plus" "harper-ls" "scls" "uwu-colors"];
          formatter = {
            command = "typstyle";
            args = ["--line-width" "100"];
          };
          auto-format = true;
        }
      ];
    };

    # Construct the snippets natively within the generated config directory
    constructFiles = {
      "external-snippets.toml" = {
        relPath = lib.mkOverride 0 "${config.binName}-config/helix/external-snippets.toml";
        output = lib.mkOverride 0 config.generatedConfig.output;
        content = builtins.readFile ./snippets.json;
        builder = ''${pkgs.remarshal}/bin/json2toml "$1" "$2"'';
      };

      "friendly-snippets" = {
        relPath = lib.mkOverride 0 "${config.binName}-config/helix/external-snippets/github.com/rafamadriz/friendly-snippets";
        output = lib.mkOverride 0 config.generatedConfig.output;
        content = ""; # Unused but required by schema
        builder = ''
          mkdir -p $(dirname "$2")
          ln -s "${pkgs.fetchFromGitHub {
            owner = "rafamadriz";
            repo = "friendly-snippets";
            rev = "572f5660cf05f8cd8834e096d7b4c921ba18e175";
            sha256 = "sha256-FzApcTbWfFkBD9WsYMhaCyn6ky8UmpUC2io/co/eByM=";
          }}" "$2"
        '';
      };

      "unicode-input-base.toml" = {
        relPath = lib.mkOverride 0 "${config.binName}-config/helix/unicode-input/base.toml";
        output = lib.mkOverride 0 config.generatedConfig.output;
        content = builtins.readFile ./unicode-input.json;
        builder = ''${pkgs.remarshal}/bin/json2toml "$1" "$2"'';
      };
    };
  };
}
