{self, ...}: {
  flake.wrappers.waybar = {
    pkgs,
    lib,
    ...
  }: {
    settings."image" = {
      # path = ./logo.png;
      size = 32;
      on-click = "${pkgs.fuzzel}/bin/fuzzel";
      interval = 5;
      tooltip = false;
    };
  };
}
