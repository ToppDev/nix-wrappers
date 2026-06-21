{...}: {
  flake.wrappers.lazygit = {
    wlib,
    pkgs,
    ...
  }: let
    configFile = (pkgs.formats.yaml {}).generate "lazygit-config.yml" {
      git = {
        autoFetch = false;
        overrideGpg = true;
        pagers = [
          {
            pager = "${pkgs.delta}/bin/delta --dark --paging=never --hyperlinks-file-link-format=\"lazygit-edit://{path}:{line}\"";
            colorArg = "always";
          }
        ];
      };
    };
  in {
    imports = [wlib.modules.default];

    package = pkgs.lazygit;

    flags = {
      "--use-config-file" = "${configFile}";
    };

    aliases = ["lg"];

    # Executes this bash snippet before the main executable runs
    runShell = [
      # bash
      ''
        # Suppress stderr on git rev-parse in case we aren't in a git repository
        if [ "$(date -r "$(git rev-parse --show-toplevel 2>/dev/null)/.git/FETCH_HEAD" +'%F' 2>/dev/null)" != "$(date +'%F')" ]; then
          echo "Fetching Git repo..."
          git fetch
        fi
      ''
    ];
  };
}
