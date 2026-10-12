{inputs, ...}: {
  flake.wrappers.neovim = {
    wlib,
    pkgs,
    ...
  }: {
    imports = [wlib.wrapperModules.neovim];

    # Main-branch build for features not yet released, notably native
    # multicursor (`:h multicursor`), which needs no configuration.
    package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;

    # Plain Lua config directory, loaded like a regular ~/.config/nvim.
    settings.config_directory = ./config;

    # The lazy loader itself has to be on the runtimepath at startup. Plugins
    # are declared with `lazy = true` in sibling files and their triggers are
    # registered with lze from config/lua/plugins/.
    specs.lze = pkgs.vimPlugins.lze;

    # No remote-plugin hosts until a plugin needs one: each pulls its whole
    # language runtime into the closure.
    hosts = {
      python3.nvim-host.enable = false;
      node.nvim-host.enable = false;
      ruby.nvim-host.enable = false;
    };

    runtimePkgs = with pkgs; [
      ripgrep
      fd
    ];
  };
}
