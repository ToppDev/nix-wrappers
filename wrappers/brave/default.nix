{...}: {
  flake.wrappers.brave = {
    wlib,
    pkgs,
    lib,
    ...
  }: rec {
    imports = [wlib.modules.default];

    package = pkgs.brave;

    drv.postBuild = let
      name = "brave-browser-incognito";
      incognitoDesktop = pkgs.makeDesktopItem {
        inherit name;
        desktopName = "Brave Incognito";
        genericName = "Incognito Web Browser";
        comment = "Access the Internet incognito";
        exec = "${lib.getExe package} --incognito %U";
        startupNotify = true;
        terminal = false;
        icon = "brave-browser";
        categories = ["Network" "WebBrowser"];
      };
    in ''
      mkdir -p $out/share/applications
      cp ${incognitoDesktop}/share/applications/${name}.desktop $out/share/applications/${name}.desktop
    '';
  };
}
