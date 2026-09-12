# @HWMON@ is replaced at launch with the runtime symlink the wrapper's
# launcher points at the CPU's hwmon directory (wrappers/waybar/default.nix).
# It cannot be a fixed path: the symlink lives in $XDG_RUNTIME_DIR, whose name
# depends on the uid, and waybar does no variable expansion of its own.
{...}: {
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
}
