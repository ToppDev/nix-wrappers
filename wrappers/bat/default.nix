{...}: {
  flake.wrappers.bat = {
    wlib,
    pkgs,
    ...
  }: {
    imports = [wlib.modules.default];

    package = pkgs.bat;
    env.BAT_CONFIG_PATH = "${./bat.conf}";
  };
}
