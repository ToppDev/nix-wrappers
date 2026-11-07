{inputs, ...}: {
  flake.wrappers.pi = {
    wlib,
    lib,
    config,
    pkgs,
    ...
  }: let
    unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    jsonFormat = pkgs.formats.json {};
    settingsFile = jsonFormat.generate "pi-settings.json" config.settings;

    # Build fixes per extension, kept here so npm-pins.json stays plain data the updater can rewrite
    extensionOverrides = {
      # Its bundled ast-grep CLI is a generic-linux binary, and it is preferred over one on PATH
      pi-lens = {
        nativeBuildInputs = [pkgs.python3 pkgs.autoPatchelfHook];
        buildInputs = [pkgs.stdenv.cc.cc.lib];
      };
      # The Agent SDK's bundled Claude Code cannot run on NixOS, and Claude Code is unfree,
      # so the shim defers to the user's own `claude`, whose login the bridge uses anyway
      pi-claude-bridge.postInstall = ''
        shim=$out/node_modules/@anthropic-ai/claude-agent-sdk-linux-x64/claude
        rm "$shim"
        cat > "$shim" <<'EOF'
        #!${pkgs.runtimeShell}
        command -v claude >/dev/null || { echo "pi-claude-bridge: no claude on PATH, install Claude Code and run 'claude auth login'" >&2; exit 127; }
        exec claude "$@"
        EOF
        chmod +x "$shim"
      '';
    };

    # Built from the published npm tarball rather than the git repo: it is what
    # pi install would fetch, already compiled, and one per package even in monorepos
    mkExtension = pin: let
      src = pkgs.fetchurl {inherit (pin) url hash;};
    in
      if pin ? npmDepsHash
      then
        unstable.buildNpmPackage ({
            # unstable's nodejs is the one pi runs on, which native addons must match
            pname = pin.name;
            inherit (pin) version npmDepsHash;
            inherit src;
            # Must match what scripts/update-npm-pins.sh generated the lock from
            postPatch = ''
              ${lib.getExe pkgs.jq} 'del(.devDependencies, .scripts, .bundleDependencies, .bundledDependencies)' package.json > package.json.tmp
              mv package.json.tmp package.json
              rm -rf node_modules
              cp ${./npm-locks + "/${pin.name}.json"} package-lock.json
            '';
            npmFlags = ["--legacy-peer-deps"]; # pi supplies its SDK to extensions, a physical copy would shadow it
            nativeBuildInputs = [pkgs.python3]; # node-gyp, for addons without a prebuilt binary
            dontNpmBuild = true;
            installPhase = ''
              runHook preInstall
              cp -r . $out
              runHook postInstall
            '';
          }
          // extensionOverrides.${pin.name} or {})
      else
        pkgs.runCommand "${pin.name}-${pin.version}" {} ''
          mkdir $out
          tar -xzf ${src} -C $out --strip-components=1
        '';
  in {
    imports = [wlib.modules.default];

    options.extensions = lib.mkOption {
      type = lib.types.listOf wlib.types.stringable;
      default = [];
      example = lib.literalExpression ''["''${pkgs.fetchFromGitHub {...}}" ./my-extension.ts]'';
      description = ''
        Extensions loaded on every launch, each an extension file or a pi package directory.

        - Passed as `--extension` flags rather than through `settings.extensions`, which the settings merge would replace wholesale and clobber whatever `pi config` wrote there
        - Adds to, never replaces, what pi discovers in the agent dir and the project

        See <https://pi.dev/docs/extensions>
      '';
    };

    options.settings = lib.mkOption {
      inherit (jsonFormat) type;
      default = {};
      example = {
        defaultProvider = "anthropic";
        defaultThinkingLevel = "medium";
        compaction.reserveTokens = 16384;
      };
      description = ''
        Global pi settings, deep-merged over the agent dir's `settings.json` at every launch.

        - pi only reads global settings from its agent dir, which also holds auth and sessions, so it cannot point at the store
        - Declared keys win, keys set through `/settings` that are not declared here survive
        - Objects merge recursively, arrays are replaced

        See <https://pi.dev/docs/settings>
      '';
    };

    config = {
      package = unstable.pi-coding-agent; # stable lags far behind a fast-moving release cycle

      # A list, since load order matters to some. The pin-update workflow opens a PR per new release
      extensions = map mkExtension (lib.importJSON ./npm-pins.json);

      addFlag =
        map (ext: ["--extension" "${ext}"]) config.extensions
        ++ [["--theme" "${./themes}"]];

      settings = {
        theme = lib.mkDefault "ayu-dark-plus"; # matches the helix wrapper's theme
        terminalTheme = lib.mkDefault false; # pi-claude-code-ui would otherwise switch pi to the `system` theme
        quietStartup = lib.mkDefault true;
        powerline.welcome = lib.mkDefault false; # pi-powerline-footer's 30 s startup splash
      };

      runtimePkgs = [
        pkgs.ffmpeg # pi-web-access: video frames, thumbnails and durations
        pkgs.yt-dlp # pi-web-access: YouTube stream URLs
        pkgs.libnotify # pi-notify: native notifications go through notify-send
      ];

      env = {
        PI_SKIP_VERSION_CHECK = "1"; # updates come through the flake, not `pi update`
        PI_TELEMETRY = "0";
        # pi-lens would fetch generic-linux binaries that cannot run here; it uses tools from PATH instead
        PI_LENS_DISABLE_TOOL_INSTALL = "1";
        PI_LENS_DISABLE_LSP_INSTALL = "1";
      };

      runShell =
        [
          # pi-subagents otherwise launches children as `node cli.js` straight from the package, skipping this wrapper's extensions
          ''export PI_SUBAGENT_PI_BINARY="''${PI_SUBAGENT_PI_BINARY:-''${BASH_SOURCE[0]}}"''
          # pi's own default, made explicit: pi-claude-code-ui falls back to ~/.pi instead and would miss the settings
          ''export PI_CODING_AGENT_DIR="''${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"''
        ]
        ++ lib.optional (config.settings != {}) ''
          pi_dir="$PI_CODING_AGENT_DIR"
          pi_settings="$pi_dir/settings.json"
          mkdir -p "$pi_dir"
          [ -s "$pi_settings" ] || echo '{}' > "$pi_settings"
          if pi_merged=$(${lib.getExe pkgs.jq} -s '.[0] * .[1]' "$pi_settings" ${settingsFile}); then
            printf '%s\n' "$pi_merged" > "$pi_settings.tmp" && mv "$pi_settings.tmp" "$pi_settings"
          else
            echo "pi wrapper: $pi_settings is not valid JSON, declared settings not applied" >&2
          fi
        '';
    };
  };
}
