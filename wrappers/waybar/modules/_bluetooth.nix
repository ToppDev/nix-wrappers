{pkgs, ...}: {
  format = "";
  format-disabled = "󰂲"; # an empty format will hide the module
  format-connected = "  {num_connections}x";
  tooltip-format = "{controller_alias}\t{controller_address}";
  tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
  tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
  tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
  on-click = "bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on";
  on-click-right = "${pkgs.blueman}/bin/blueman-manager";
}
