{...}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.syssuspend = pkgs.writeShellApplication {
      name = "syssuspend";
      text = ''
        # A script to suspend the computer

        if ! ${self'.packages.syspre}/bin/syspre "suspend"; then
          exit 1
        fi

        ${pkgs.systemd}/bin/systemctl suspend
      '';
    };
  };
}
