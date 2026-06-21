{
  self,
  pkgs,
  lib,
  ...
}: let
  selfpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
in {
  interval = 1;
  format = "   {usage}%";
  # format ="  {icon0}{icon1}{icon2}{icon3}{icon4}{icon5}{icon6}{icon7}{icon8}{icon9}{icon10}{icon11}{icon12}{icon13}{icon14}{icon15}{icon16}{icon17}{icon18}{icon19}{icon20}{icon21}{icon22}{icon23}";
  format-icons = [
    "<span color='#69ff94'>▁</span>"
    "<span color='#9fff8f'>▂</span>"
    "<span color='#c6ff8f'>▃</span>"
    "<span color='#e5ff96'>▄</span>"
    "<span color='#ffffa5'>▅</span>"
    "<span color='#ffcc7f'>▆</span>"
    "<span color='#ff9977'>▇</span>"
    "<span color='#dd532e'>█</span>"
  ];
  on-click = "${lib.getExe selfpkgs.wezterm} -e ${lib.getExe pkgs.btop}";
}
