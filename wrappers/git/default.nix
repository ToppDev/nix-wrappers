{...}: {
  flake.wrappers.git = {
    wlib,
    pkgs,
    lib,
    ...
  }: {
    imports = [wlib.wrapperModules.git];

    settings = {
      commit = {
        gpgSign = true;
      };
      credential = {
        helper = "cache --timeout=86400";
      };
      delta = {
        dark = true;
        hyperlinks = true;
        line-numbers = true;
        navigate = true;
        side-by-side = false;
        wrap-max-lines = 10;
      };
      diff = {
        colorMoved = "default";
      };
      init = {
        defaultBranch = "main";
      };
      interactive = {
        diffFilter = "${lib.getExe pkgs.delta} --color-only";
      };
      merge = {
        conflictstyle = "zdiff3";
      };
      pager = {
        blame = "${lib.getExe pkgs.delta}";
        diff = "${lib.getExe pkgs.delta}";
        log = "${lib.getExe pkgs.delta}";
        show = "${lib.getExe pkgs.delta}";
      };
      tag = {
        gpgSign = true;
      };
    };
  };
}
