{...}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.syslogout = pkgs.writeShellApplication {
      name = "syslogout";
      text = ''
        # A script to logout the computer

        if ! ${self'.packages.syspre}/bin/syspre "logout"; then
          exit 1
        fi

        # ${pkgs.hyprland}/bin/hyprctl dispatch exit
        ${pkgs.hyprland}/bin/hyprctl dispatch "hl.dsp.exec_cmd(\"uwsm stop\")"

        # This does not shutdown hyprland and uwsm properly
        # loginctl terminate-user ""
      '';
    };
  };
}
