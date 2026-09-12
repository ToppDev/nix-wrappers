{self, ...}: {
  flake.wrappers.waybar = {
    pkgs,
    lib,
    ...
  }: {
    settings."custom/brave" = let
      selfpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
    in {
      format = "";
      on-click = "${lib.getExe selfpkgs.brave}";
      tooltip-format = "Brave";
    };
  };
}
