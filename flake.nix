{
  description = "ToppDev's Nix wrappers";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    hyprland.url = "github:hyprwm/Hyprland/v0.55.4";
    hyprsplit = {
      url = "github:shezdy/hyprsplit/main";
      inputs.hyprland.follows = "hyprland";
    };
    # Replacement for hyprsplit
    # split-monitor-workspaces = {
    #   url = "github:zjeffer/split-monitor-workspaces/v0.55.4";
    #   inputs.hyprland.follows = "hyprland";
    # };

    helix.url = "github:helix-editor/helix/master";
  };

  # Import all .nix files from current directory except flake.nix recursively
  outputs = inputs: let
    inherit (inputs.nixpkgs) lib;
    inherit (lib.fileset) toList fileFilter;

    isNixModule = file:
      file.hasExt "nix"
      && file.name != "flake.nix"
      && !lib.hasPrefix "_" file.name;

    # See https://github.com/vic/import-tree
    importTree = path:
      toList (fileFilter isNixModule path);
  in
    inputs.flake-parts.lib.mkFlake
    {inherit inputs;}
    {
      systems = [
        "x86_64-linux"
        # "x86_64-darwin"
        "aarch64-linux"
        # "aarch64-darwin"
      ];

      imports =
        [
          inputs.wrapper-modules.flakeModules.default
        ]
        ++ importTree ./wrappers;

      flake = {
        flakeModules.wrappers = {
          imports = importTree ./wrappers;
        };
      };
    };
}
