{self, ...}: {
  flake.wrappers.waybar = {
    pkgs,
    lib,
    ...
  }: {
    settings."hyprland/workspaces" = {
      # format = "{id}{icon}";
      # format-icons = {
      #   # "" "" "" ""
      #   "active" = ""; # Will be shown when workspace is active
      #   "default" = ""; # Will be shown when no string matches is found.
      #   "empty" = ""; # Will be shown on active empty workspaces
      #   "persistent" = ""; # Will be shown on non-active persistent workspaces
      #   "special" = ""; # Will be shown on non-active special workspaces
      #   "urgent" = ""; # Will be shown on non-active urgent workspaces
      # };
      all-outputs = false;
      # persistent-workspaces = {
      #   "*" = 5;
      # };

      "format" = "{icon}  {windows}";
      format-icons = {
        "11" = "1";
        "12" = "2";
        "13" = "3";
        "14" = "4";
        "15" = "5";
        "16" = "6";
        "17" = "7";
        "18" = "8";
        "19" = "9";
        "20" = "10";
        "21" = "1";
        "22" = "2";
        "23" = "3";
        "24" = "4";
        "25" = "5";
        "26" = "6";
        "27" = "7";
        "28" = "8";
        "29" = "9";
        "30" = "10";
      };
      "format-window-separator" = " ";
      "window-rewrite-default" = "";
      "window-rewrite" = {
        "title<.*youtube.*>" = "";
        "title<.*github.*>" = "";
        "class<brave-browser>" = "";
        "class<firefox>" = "";
        "class<thunderbird>" = "";
        "class<vlc>" = "󰕼";
        "class<Logseq>" = "󰠮";
        "class<Mattermost>" = "󰭹";
        "class<Zotero>" = "";
        "class<steam>" = "";
        "class<org.kde.okular>" = "";
        "class<org.wezfurlong.wezterm>" = "";
        "class<org.wezfurlong.wezterm> title<.*yazi.*>" = "";
        "class<.virt-manager-wrapped> title<Virtual Machine Manager>" = "";
        "class<.virt-manager-wrapped> title<win10.*>" = "";
        "class<code|codium>" = "󰨞";
      };
    };
  };
}
