{pkgs, ...}: {
  scroll-step = 3; # %, can be a float
  max-volume = 200;
  format = "{icon}   {volume}%";
  format-bluetooth = " {icon}   {volume}%";
  format-bluetooth-muted = "   {icon}   {volume}%";
  format-muted = "    {volume}%";
  format-source = "{volume}% ";
  format-source-muted = "";
  format-icons = {
    headphone = "";
    hands-free = "󰟅";
    headset = "";
    phone = "";
    portable = "";
    car = "";
    default = [
      ""
      ""
      " "
    ];
  };
  on-click = "${pkgs.pamixer}/bin/pamixer --toggle-mute";
  on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
}
