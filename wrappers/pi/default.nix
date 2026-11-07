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
  in {
    imports = [wlib.modules.default];

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

      env = {
        PI_SKIP_VERSION_CHECK = "1"; # updates come through the flake, not `pi update`
        PI_TELEMETRY = "0";
      };

      runShell = lib.optional (config.settings != {}) ''
        pi_dir="''${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
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
