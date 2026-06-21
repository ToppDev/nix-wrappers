{...}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.syshibernate = pkgs.writeShellApplication {
      name = "syshibernate";
      text = ''
        # A script to hibernate the computer

        if ! ${self'.packages.syspre}/bin/syspre "hibernate"; then
          exit 1
        fi

        ${pkgs.systemd}/bin/systemctl hibernate
      '';
    };
  };
}
