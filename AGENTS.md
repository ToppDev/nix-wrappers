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

This repo is consumed two different ways, and a change must keep both working:

- As a **flake input**: the consumer imports `flakeModules.wrappers` and re-evaluates the whole module tree against its own `pkgs` and `self`, then merges its own `flake.wrappers.<tool>` declarations on top
  - A module's `inputs` argument stays bound to **this** flake's inputs (`withOwnInputs` in `flake.nix`), so a wrapper may read any input declared here and consumers never have to declare it
  - A consumer swaps one only via `inputs.wrappers.inputs.<name>.follows`
- As a **direct run**: `nix run github:ToppDev/nix-wrappers#<tool>` builds `packages.<system>.<tool>` from this flake alone — nothing from any consumer is merged in

Consequences a wrapper author must respect:

- A wrapper must never *require* an option that only a consumer sets — anything host- or user-specific needs a working default so the standalone build still produces a usable tool
- Removing or slimming what a wrapper bundles silently degrades the standalone run for everyone, even when the motivation came from a consumer that wanted to differ — per-consumer divergence belongs in the consumer, via re-declaring `flake.wrappers.<tool>` or `.wrap {...}`
- Both paths must be checked before a change is pushed

## CI

- A GitHub Actions workflow builds every wrapper on `x86_64-linux`, one job per wrapper
- A separate job consumes the flake as an input and evaluates it, covering the flake-input path
- Both jobs run on every push and pull request
- A weekly workflow bumps `flake.lock` on a side branch, runs the full CI pipeline against it and fast-forwards `main` only if everything passed
- A weekly workflow opens one PR per new release of an npm package pinned in a `wrappers/<tool>/npm-pins.json`
  - Use it for third-party code that should be reviewed before it lands, rather than a flake input the lock bump moves silently
  - The file is plain data that `scripts/update-npm-pins.sh` rewrites, together with a generated lock per package under `npm-locks/`. Build fixes belong in the wrapper's Nix code
  - To add a package, append an entry with an empty `version` and run the script with `--all` (it needs `nodejs` and `prefetch-npm-deps`)
  - It dispatches CI on the PR branch itself, since a PR opened with `GITHUB_TOKEN` triggers no workflows
- `aarch64-linux` is deliberately out of scope

## Verify changes

```
nix flake check
nix build --dry-run .#<tool>   # for each wrapper touched
```

## Documentation

- nix-wrapper-modules — <https://nix-community.github.io/nix-wrapper-modules>
- flake-parts — <https://flake.parts>
