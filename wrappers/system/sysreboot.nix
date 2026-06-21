{...}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.sysreboot = pkgs.writeShellApplication {
      name = "sysreboot";
      text = ''
        # A script to reboot the computer

        if ! ${self'.packages.syspre}/bin/syspre "reboot"; then
          exit 1
        fi

        ${pkgs.systemd}/bin/systemctl reboot
      '';
    };
  };
}
