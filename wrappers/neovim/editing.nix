{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    specs.editing = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        # The nixpkgs build predates Neovim 0.13 support: its jump search
        # reads a C global the nightly no longer exports and fails with
        # "undefined symbol: search_match_lines". Drop the override once
        # nixpkgs carries a version from 2026-08-22 or later.
        (flash-nvim.overrideAttrs {
          version = "2.1.0-unstable-2026-08-22";
          src = pkgs.fetchFromGitHub {
            owner = "folke";
            repo = "flash.nvim";
            rev = "5f0f270fdc7c5b0c21d903ee85b9cb06f2ac636a";
            hash = "sha256-88DoXkz8M6ehkzS9VNu2/T0FENpduTbgiUZd+GeVVX4=";
          };
        })
        nvim-treesitter-textobjects
        mini-surround
        nvim-autopairs
      ];
    };
  };
}
