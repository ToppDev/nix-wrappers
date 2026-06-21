{...}: {
  flake.wrappers.nextcloud-client = {
    wlib,
    pkgs,
    lib,
    config,
    ...
  }: let
    cfg = config.nextcloud;
    inherit (lib) mkOption types;

    concatFolders = mapFn:
      builtins.concatStringsSep "\" \"" (
        builtins.concatLists (
          lib.mapAttrsToList (
            name: server:
              map (f: mapFn name server f) server.folders
          )
          cfg.ensureServers
        )
      );

    servers = concatFolders (name: server: f: name);
    urls = concatFolders (name: server: f: server.url);
    davUser = concatFolders (name: server: f: server.davUser);
    webflowUser = concatFolders (name: server: f: server.webflowUser);
    targetPath = concatFolders (name: server: f: f.targetPath);
    localPath = concatFolders (name: server: f: f.localPath);
    virtualFilesMode = concatFolders (name: server: f:
      if f.virtualFilesMode
      then "on"
      else "off");
    paused = concatFolders (name: server: f: lib.boolToString f.paused);
    ignoreHiddenFiles = concatFolders (name: server: f: lib.boolToString f.ignoreHiddenFiles);

    nc-header = ''
      [General]
      isVfsEnabled=false
      launchOnSystemStartup=${lib.boolToString cfg.launchOnSystemStartup}
      optionalServerNotifications=${lib.boolToString cfg.optionalServerNotifications}
      overrideLocalDir=
      overrideServerUrl=
      showCallNotifications=${lib.boolToString cfg.showCallNotifications}

      [Accounts]

      [Settings]
    '';
  in {
    imports = [wlib.modules.default];

    options.nextcloud = {
      launchOnSystemStartup = mkOption {
        type = types.bool;
        default = false;
      };
      optionalServerNotifications = mkOption {
        type = types.bool;
        default = true;
      };
      showCallNotifications = mkOption {
        type = types.bool;
        default = true;
      };

      ensureServers = mkOption {
        default = {};
        type = with types;
          attrsOf (submodule ({name, ...}: {
            options = {
              name = mkOption {
                type = str;
                default = name;
                readOnly = true;
              };
              url = mkOption {type = str;};
              davUser = mkOption {type = str;};
              webflowUser = mkOption {type = str;};
              folders = mkOption {
                default = [];
                type = listOf (submodule {
                  options = {
                    localPath = mkOption {type = str;};
                    targetPath = mkOption {type = str;};
                    virtualFilesMode = mkOption {
                      type = bool;
                      default = false;
                    };
                    paused = mkOption {
                      type = bool;
                      default = true;
                    };
                    ignoreHiddenFiles = mkOption {
                      type = bool;
                      default = false;
                    };
                  };
                });
              };
            };
          }));
      };
    };

    config = {
      package = pkgs.nextcloud-client;
      runShell = [
        # bash
        ''
          cfgDir="''${XDG_CONFIG_HOME:-$HOME/.config}/Nextcloud"
          cfgFile="$cfgDir/nextcloud.cfg"

          mkdir -p "$cfgDir"

          if [ ! -f "$cfgFile" ]; then
            echo "${nc-header}" >> "$cfgFile"
          else
            ${pkgs.gnused}/bin/sed -i "s/launchOnSystemStartup=.*/launchOnSystemStartup=${lib.boolToString cfg.launchOnSystemStartup}/" "$cfgFile"
            ${pkgs.gnused}/bin/sed -i "s/optionalServerNotifications=.*/optionalServerNotifications=${lib.boolToString cfg.optionalServerNotifications}/" "$cfgFile"
            ${pkgs.gnused}/bin/sed -i "s/showCallNotifications=.*/showCallNotifications=${lib.boolToString cfg.showCallNotifications}/" "$cfgFile"
          fi

          servers=("${servers}")
          urls=("${urls}")
          davUser=("${davUser}")
          webflowUser=("${webflowUser}")
          targetPath=("${targetPath}")
          localPath=("${localPath}")
          virtualFilesMode=("${virtualFilesMode}")
          paused=("${paused}")
          ignoreHiddenFiles=("${ignoreHiddenFiles}")

          cfgChanged=false
          function addConfig(){
            if ! $cfgChanged; then
              cfgTmpSettings=$(mktemp)
              cfgTmp=$(mktemp)
              accounts=false
              settings=false
              while read -ru 10 p; do
                [ "$p" = "[Accounts]" ] && accounts=true
                [ "$p" = "[Settings]" ] && settings=true
                $accounts && [ "$p" = "" ] && continue
                $settings && echo "$p" >> "$cfgTmpSettings" || echo "$p" >> "$cfgTmp"
              done 10<"$cfgFile"
              mv -f "$cfgTmp" "$cfgFile"
            fi
            echo "$1" >> "$cfgFile"
            cfgChanged=true
          }

          if [ ''${#servers[@]} -gt 0 ] && [ -n "''${servers[0]}" ]; then
            for i in "''${!servers[@]}"; do
              if ${pkgs.gnugrep}/bin/grep -e "^[0-9]*\\\\url=''${urls[$i]}$" "$cfgFile" > /dev/null; then
                server_id=$(${pkgs.gnugrep}/bin/grep -e "^[0-9]*\\\\url=''${urls[$i]}$" "$cfgFile" \
                             | ${pkgs.coreutils}/bin/cut -d\\ -f1)
              else
                if ${pkgs.gnugrep}/bin/grep -q '^[0-9]*\\' "$cfgFile"; then
                  server_id=$(${pkgs.gnugrep}/bin/grep -e '^[0-9]*\\' "$cfgFile" \
                               | ${pkgs.coreutils}/bin/cut -d\\ -f1 | sort | tail -n1)
                else
                  server_id=-1
                fi
                server_id=$((server_id+1))
                addConfig "$server_id\\authType=webflow"
                addConfig "$server_id\\dav_user=''${davUser[$i]}"
                addConfig "$server_id\\displayName=''${servers[$i]}"
                addConfig "$server_id\\url=''${urls[$i]}"
                addConfig "$server_id\\webflow_user=''${webflowUser[$i]}"
              fi

              if ! ${pkgs.gnugrep}/bin/grep -e "^$server_id\\\\Folders\\\\[0-9]*\\\\targetPath=''${targetPath[$i]}$" "$cfgFile" > /dev/null; then
                if ${pkgs.gnugrep}/bin/grep -q '^[0-9]*\\Folders' "$cfgFile"; then
                  folder_id=$(${pkgs.gnugrep}/bin/grep -e '^[0-9]*\\Folders' "$cfgFile" | ${pkgs.coreutils}/bin/cut -d\\ -f3 | sort | tail -n1)
                else
                  folder_id=0
                fi
                folder_id=$((folder_id+1))
                folder_prefix="$server_id\\Folders\\$folder_id"
                addConfig "$folder_prefix\\ignoreHiddenFiles=''${ignoreHiddenFiles[$i]}"
                addConfig "$folder_prefix\\localPath=''${localPath[$i]}"
                addConfig "$folder_prefix\\paused=''${paused[$i]}"
                addConfig "$folder_prefix\\targetPath=''${targetPath[$i]}"
                addConfig "$folder_prefix\\virtualFilesMode=''${virtualFilesMode[$i]}"
                mkdir -p "''${localPath[$i]}"
              fi
            done
          fi

          if $cfgChanged; then
            echo "" >> "$cfgFile"
            cat "$cfgTmpSettings" >> "$cfgFile"
            rm "$cfgTmpSettings"
          fi
        ''
      ];
    };
  };
}
