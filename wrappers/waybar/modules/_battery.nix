{pkgs, ...}: {
  states = {
    good = 95;
    warning = 30;
    critical = 15;
  };
  format = "{icon}   {capacity}%";
  format-charging = "󰂄  {capacity}%";
  format-plugged = "  {capacity}%";
  format-alt = "{icon}   {time}";
  # format-full = "{capacity}% {icon}";
  # format-good = ""; # An empty format will hide the module
  format-icons = [
    ""
    ""
    ""
    ""
    ""
  ];
}
