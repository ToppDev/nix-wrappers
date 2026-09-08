# nix-wrappers

Public flake of standalone, declarative per-app wrappers. Dendritic flake-parts pattern on top of the `wrapper-modules` input (`github:BirdeeHub/nix-wrapper-modules`).

## Layout

- One directory per tool under `wrappers/`, declaring `flake.wrappers.<tool>` in its `default.nix`
- Non-`.nix` assets (config files, stylesheets) sit beside the wrapper, referenced by relative path
- `wrappers/system/` is a **second, unrelated convention**: `perSystem.packages.sys<verb> = pkgs.writeShellApplication {...}` session and power scripts, not `flake.wrappers`

## Outputs

- `self.packages.<system>.<tool>` — the built wrapper
- `flake.flakeModules.wrappers` — the whole tree, re-exported for consumers

## Auto-import

`flake.nix` defines an `importTree` helper over `./wrappers`: every `*.nix` below it is loaded as a flake-parts module, so **creating the file is the whole registration step**. It skips `flake.nix` and any name starting with `_`.

- **Don't add `_`-prefixed files** — a manually `import`-ed file sits outside the module system everything else is built on
- To split a large wrapper, add ordinary sibling files that each re-declare `flake.wrappers.<tool>` and let module merging combine them
- A few legacy `_` files remain; migrate them to sibling files when touched

## Writing a wrapper

```nix
{...}: {
  flake.wrappers.<tool> = {
    wlib,
    pkgs,
    ...
  }: {
    imports = [wlib.modules.default];

    package = pkgs.<tool>;
    # settings / env / flags / runtimePkgs as needed
  };
}
```

- `wlib.modules.default` is the generic base
- `wlib.wrapperModules.<tool>` instead where the framework ships a tool-specific one, which brings that tool's own options
- Reference another wrapped tool as `self.packages.${pkgs.stdenv.hostPlatform.system}.<tool>`, usually bound as `selfpkgs`

## Consumers

**This repo is public. Never name or describe the private downstream config here** — no repo name, host names, addresses, secrets layout or paths into it. Write for an unknown consumer.

- A consumer doesn't fork a wrapper; it re-declares the same `flake.wrappers.<name>` with its own host/user-specific bits and relies on module merging
- Consumers track `github:ToppDev/nix-wrappers`, so a change lands only after it is pushed and their lock updated
- To test end-to-end, point the consuming flake's `wrappers` input at a local checkout and rebuild there

## Verify changes

```
nix flake check
nix build .#<tool>   # for each wrapper touched
```

## Documentation

- nix-wrapper-modules — <https://nix-community.github.io/nix-wrapper-modules>
- flake-parts — <https://flake.parts>
