{self, ...}: {
  flake.wrappers.waybar = {
    pkgs,
    lib,
    ...
  }: {
    settings."memory" = let
      selfpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
    in {
      format = "   {used:0.1f}/{total:0.1f} GiB";
      tooltip-format = "Mem:  {used:0.1f}/{total:0.1f} GiB\nSwap: {swapUsed:0.1f}/{swapTotal:0.1f} GiB";
      on-click = "${lib.getExe selfpkgs.wezterm} -e ${lib.getExe pkgs.btop}";
    };
  };
}
