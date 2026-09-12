{...}: {
  flake.wrappers.git = {
    wlib,
    pkgs,
    lib,
    ...
  }: {
    imports = [wlib.wrapperModules.git];

    # The module points GIT_CONFIG_GLOBAL at the generated file, which
    # *replaces* ~/.gitconfig rather than layering onto it — so without this
    # the wrapper hides the user's identity, signing key and aliases, and
    # there is no way to get them back short of editing this repo. The
    # include is appended after `settings`, so anything the user sets wins
    # over the defaults below.
    configFile.content = ''
      [include]
        path = ~/.gitconfig
    '';

    settings = {
      # Signing is deliberately not forced here. It needs a `user.signingkey`
      # that only the person running it can supply, and with it on by default
      # a standalone `nix run github:ToppDev/nix-wrappers#git` aborts every
      # commit with "gpg failed to sign the data". Turn it on in your own
      # ~/.gitconfig, which the include above picks up.
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
      fetch = {
        prune = true;
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
    };
  };
}
