{...}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.syspoweroff = pkgs.writeShellApplication {
      name = "syspoweroff";
      text = ''
        # A script to poweroff the computer

        if ! ${self'.packages.syspre}/bin/syspre "shutdown"; then
          exit 1
        fi

        ${pkgs.systemd}/bin/systemctl poweroff
      '';
    };
  };
}
