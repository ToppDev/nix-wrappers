{...}: {
  flake.wrappers.nixos-rollback = {
    wlib,
    pkgs,
    ...
  }: {
    imports = [wlib.modules.default];

    package = pkgs.writeShellApplication {
      name = "nixos-rollback";
      text = ''
        # Switch to root user
        if [ "$(whoami)" != "root" ]; then
          echo "Root required to run this script. Please authenticate..."
          sudo su -s "$0"
          exit
        fi

        id=$(nix-env --list-generations --profile /nix/var/nix/profiles/system | ${pkgs.fzf}/bin/fzf | ${pkgs.gawk}/bin/awk '{ print $1 }')
        if [ -z "$id" ]; then
          echo "No generation selected. Doing nothing."
          exit 0
        fi

        nix-env --switch-generation "$id" -p /nix/var/nix/profiles/system
        /nix/var/nix/profiles/system/bin/switch-to-configuration switch
      '';
    };
  };
}
