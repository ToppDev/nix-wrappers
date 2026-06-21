{...}: {
  flake.wrappers.kitty = {wlib, ...}: {
    imports = [wlib.wrapperModules.kitty];

    font = {
      name = "FiraCode Nerd Font";
      size = 12;
    };
  };
}
