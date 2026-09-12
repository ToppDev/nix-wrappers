{self, ...}: {
  flake.wrappers.waybar = {
    pkgs,
    lib,
    ...
  }: {
    settings."custom/appmenu" = {
      format = "󱄅"; # 󰀻
      on-click = "${pkgs.fuzzel}/bin/fuzzel";
      tooltip-format = "Apps";
    };
  };
}
