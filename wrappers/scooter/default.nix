{...}: {
  flake.wrappers.scooter = {
    wlib,
    pkgs,
    ...
  }: let
    configFile = (pkgs.formats.toml {}).generate "config.toml" {
      preview = {
        wrap_text = true;
        syntax_highlighting_theme = "Catppuccin Mocha";
      };
      search = {
        disable_prepopulated_fields = false;
      };
    };
    catppuccinThemes = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "bat";
      rev = "6810349b28055dce54076712fc05fc68da4b8ec0"; # 2025-06-30
      hash = "sha256-lJapSgRVENTrbmpVyn+UQabC9fpV1G1e+CdlJ090uvg=";
    };
    configDir = pkgs.runCommand "scooter-config-dir" {} ''
      mkdir -p $out/themes
      cp ${configFile} $out/config.toml
      cp ${catppuccinThemes}/themes/*.tmTheme $out/themes/
    '';
  in {
    imports = [wlib.modules.default];

    package = pkgs.scooter;

    addFlag = [
      ["--config-dir" "${configDir}"]
    ];
  };
}
