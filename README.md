# Nix Wrappers

A collection of standalone, declarative Nix wrappers for configuring desktop applications and development tools. 

This repository utilizes [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules) to manage user environments and application configurations directly via NixOS flakes.

## Usage

### Run

```bash
nix run github:ToppDev/nix-wrappers
```

### Include into a nix configuration

These wrappers are designed to be imported as a flake input into a dendritic pattern configuration.

**flake.nix**
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    wrappers = {
      url = "github:ToppDev/nix-wrappers";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
      # if you want to use hyprland also include these
      inputs.hyprland.follows = "hyprland"; 
      inputs.hyprsplit.follows = "hyprsplit";
    };
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
          inputs.wrapper-modules.flakeModules.wrappers
          inputs.wrappers.flakeModules.wrappers
        ]
        ++ importTree ./modules;
    };
}
```
