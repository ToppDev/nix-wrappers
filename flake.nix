{
  description = "ToppDev's Nix wrappers";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # For the few packages that need to track upstream faster than a release
    # (devenv). Downstream flakes can `follows` their own unstable pin.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    # Neovim built from the main branch, for features not yet in a release
    # (native multicursor). nixpkgs is deliberately not followed: the overlay's
    # own pin is what the nix-community binary cache builds against.
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # Consumed only as a source tree — wrappers/hyprland copies its files into
    # the plugin directory — so `flake = false` is the honest declaration. It
    # also drops the whole hyprland input this used to carry solely so that
    # hyprsplit could `follows` it, and with it a dozen hypr* lock entries that
    # every consumer inherited. The compositor itself comes from pkgs.hyprland.
    hyprsplit = {
      url = "github:shezdy/hyprsplit/main";
      flake = false;
    };
    # Replacement for hyprsplit
    # split-monitor-workspaces = {
    #   url = "github:zjeffer/split-monitor-workspaces/v0.55.4";
    #   inputs.hyprland.follows = "hyprland";
    # };
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

    # Pins a module's `inputs` argument to this flake's own inputs. A consumer
    # importing flakeModules.wrappers would otherwise hand the modules *its*
    # inputs, forcing it to declare every input a wrapper reads. It can still
    # override one through `inputs.<name>.follows` on this flake. `self` is left
    # alone so selfpkgs keeps resolving to the consumer's merged packages.
    withOwnInputs = file: let
      module = import file;
    in {
      _file = file;
      key = toString file;
      imports = [
        (
          if lib.isFunction module
          then lib.setFunctionArgs (args: module (args // {inherit inputs;})) (lib.functionArgs module)
          else module
        )
      ];
    };

    wrapperModules = map withOwnInputs (importTree ./wrappers);
  in
    inputs.flake-parts.lib.mkFlake
    {inherit inputs;}
    {
      # aarch64 is deliberately out of scope: CI never built it, so exporting
      # packages.aarch64-linux.* only published outputs that could break
      # indefinitely without anything noticing.
      systems = [
        "x86_64-linux"
        # "x86_64-darwin"
        # "aarch64-darwin"
      ];

      imports =
        [
          inputs.wrapper-modules.flakeModules.default
        ]
        ++ wrapperModules;

      perSystem = {pkgs, ...}: {
        # `nix fmt` in a repo that is uniformly alejandra-formatted.
        formatter = pkgs.alejandra;

        # Gives `nix flake check` something to check beyond evaluation. Only the
        # .nix files are copied into the store, so touching an asset or the
        # README does not invalidate it.
        checks.formatting =
          pkgs.runCommand "check-formatting" {
            nativeBuildInputs = [pkgs.alejandra];
            src = lib.fileset.toSource {
              root = ./.;
              fileset = fileFilter (file: file.hasExt "nix") ./.;
            };
          } ''
            alejandra --check "$src"
            touch "$out"
          '';
      };

      flake = {
        flakeModules.wrappers = {
          imports = wrapperModules;
        };
      };
    };
}
