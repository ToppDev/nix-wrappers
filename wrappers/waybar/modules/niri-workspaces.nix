{self, ...}: {
  flake.wrappers.waybar = {
    pkgs,
    lib,
    ...
  }: {
    settings."niri/workspaces" = {
      format = "{icon}";
      format-icons = {
        "urgent" = ""; # "",
        "focused" = ""; # "", ""
        "default" = ""; # ""
      };
    };
  };
}
