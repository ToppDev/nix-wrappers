{
  self,
  pkgs,
  lib,
  ...
}: let
  selfpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
in {
  format = "";
  on-click = "${lib.getExe selfpkgs.brave}";
  tooltip-format = "Brave";
}
