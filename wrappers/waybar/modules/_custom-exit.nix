{
  self,
  pkgs,
  lib,
  ...
}: let
  selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
in {
  format = "";
  on-click = "${lib.getExe selfpkgs.wlogout}";
  tooltip = false;
}
