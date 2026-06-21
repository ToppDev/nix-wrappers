{...}: {
  flake.wrappers.neovim = {
    wlib,
    lib,
    ...
  }: {
    imports = [wlib.wrapperModules.neovim];
  };
}
