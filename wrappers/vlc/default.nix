{...}: {
  flake.wrappers.vlc = {
    wlib,
    pkgs,
    ...
  }: {
    imports = [wlib.modules.default];

    package = pkgs.vlc;

    # Make VLC search for our extensions in the wrapper
    env.VLC_DATA_PATH = "${placeholder "out"}/share/vlc";

    constructFiles = {
      vlc-delete = {
        relPath = "share/vlc/lua/extensions/vlc-delete.lua";
        content = builtins.readFile ./vlc-delete.lua;
      };
      shuffle = {
        relPath = "share/vlc/lua/extensions/shuffle.lua";
        content = builtins.readFile ./shuffle.lua;
      };
    };
  };
}
