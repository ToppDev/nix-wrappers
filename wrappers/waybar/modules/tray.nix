{self, ...}: {
  flake.wrappers.waybar = {
    pkgs,
    lib,
    ...
  }: {
    settings."tray" = {
      # icon-size = 21;
      spacing = 10;
    };
  };
}
