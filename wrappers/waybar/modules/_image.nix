{pkgs, ...}: {
  # path = ./logo.png;
  size = 32;
  on-click = "${pkgs.fuzzel}/bin/fuzzel";
  interval = 5;
  tooltip = false;
}
