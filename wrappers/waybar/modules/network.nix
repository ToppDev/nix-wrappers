{self, ...}: {
  flake.wrappers.waybar = {
    pkgs,
    lib,
    ...
  }: {
    settings."network" = {
      # interface = "wlp2*"; # (Optional) To force the use of this interface
      format = "{ifname}";
      format-wifi = "    {signalStrength}%";
      format-ethernet = "󰈁   {ipaddr}/{cidr}";
      format-linked = "󰈂    {ifname} (No IP)";
      format-disconnected = ""; # empty format hides the module
      tooltip-format = "{ifname} via {gwaddr}";
      tooltip-format-wifi = "     {essid} ({signalStrength}%)";
      tooltip-format-ethernet = "    {ifname} ({ipaddr}/{cidr})";
      tooltip-format-disconnected = "Disconnected";
      # format-alt = "{ifname}: {ipaddr}/{cidr}";
    };
  };
}
