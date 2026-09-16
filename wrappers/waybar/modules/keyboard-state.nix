{self, ...}: {
  flake.wrappers.waybar = {
    pkgs,
    lib,
    ...
  }: {
    settings."keyboard-state" = {
      numlock = true;
      capslock = true;
      format = "{name} {icon}";
      format-icons = {
        locked = "";
        unlocked = "";
      };
    };
  };
}
