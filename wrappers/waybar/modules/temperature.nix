{self, ...}: {
  flake.wrappers.waybar = {
    pkgs,
    lib,
    ...
  }: {
    settings."temperature" = {
      interval = 2;
      hwmon-path = "@HWMON@/temp1_input";
      critical-threshold = 95;
      format-critical = "<span color='#dc2f2f'>{icon}  {temperatureC}°C</span>";
      format = "{icon}  {temperatureC}°C";
      format-icons = [
        "<span color='#69ff94'></span>"
        "<span color='#9fff8f'></span>"
        "<span color='#c6ff8f'></span>"
        "<span color='#e5ff96'></span>"
        "<span color='#ffffa5'></span>"
        "<span color='#ffcc7f'></span>"
        "<span color='#ff9977'></span>"
        "<span color='#dd532e'></span>"
      ];
      tooltip = false;
    };
  };
}
