#!/usr/bin/env bash
# Pins npm packages listed in wrappers/<tool>/npm-pins.json.
#
#   update-npm-pins.sh --list         JSON array of outdated "<tool>/<name>" entries
#   update-npm-pins.sh <tool>/<name>  pin that entry to its latest version
#   update-npm-pins.sh --all          pin every outdated entry
#
# Each entry is {name, package, version, url, hash} plus npmDepsHash when the
# package has dependencies. An entry with an empty version is new and gets
# pinned on the next run. Needs curl, jq, npm and prefetch-npm-deps.
set -euo pipefail

cd "$(dirname "$0")/.."
registry=https://registry.npmjs.org

# Same edit the Nix build applies before `npm ci`, so the lock matches the package.json it is installed from:
# - devDependencies would pull in the full pi SDK and toolchains
# - scripts would run the publisher's prepare/postinstall hooks
# - bundled dependencies would be wiped by `npm ci` with no lock entry to restore them from
strip_manifest() { rm -rf node_modules; jq 'del(.devDependencies, .scripts, .bundleDependencies, .bundledDependencies)' package.json > package.json.tmp && mv package.json.tmp package.json; }

latest() { curl -sf "$registry/${1/\//%2F}/latest"; }

outdated() {
  for file in wrappers/*/npm-pins.json; do
    [ -e "$file" ] || continue
    tool="$(basename "$(dirname "$file")")"
    jq -r '.[] | "\(.name) \(.package) \(.version)"' "$file" | while read -r name pkg version; do
      [ "$(latest "$pkg" | jq -r .version)" = "$version" ] || echo "$tool/$name"
    done
  done
}

pin() {
  local tool="${1%%/*}" name="${1#*/}"
  local file="wrappers/$tool/npm-pins.json" lockdir="wrappers/$tool/npm-locks"
  local pkg meta version url hash deps_hash=""
  pkg="$(jq -er --arg n "$name" '.[] | select(.name == $n) | .package' "$file")"
  meta="$(latest "$pkg")"
  version="$(jq -r .version <<<"$meta")"
  url="$(jq -r .dist.tarball <<<"$meta")"
  hash="$(jq -r .dist.integrity <<<"$meta")" # npm's own SRI hash of the tarball, which fetchurl accepts as is

  if [ "$(jq '.dependencies // {} | length' <<<"$meta")" -gt 0 ]; then
    local work
    work="$(mktemp -d)"
    curl -sfL "$url" | tar -xz -C "$work"
    (
      cd "$work/package"
      strip_manifest
      # --legacy-peer-deps: pi supplies its SDK packages to extensions, a physical copy would shadow them
      npm install --package-lock-only --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent
    )
    mkdir -p "$lockdir"
    cp "$work/package/package-lock.json" "$lockdir/$name.json"
    deps_hash="$(prefetch-npm-deps "$lockdir/$name.json" 2>/dev/null)"
    rm -rf "$work"
  else
    rm -f "$lockdir/$name.json"
  fi

  jq --indent 2 --arg n "$name" --arg v "$version" --arg u "$url" --arg h "$hash" --arg d "$deps_hash" '
    map(if .name == $n then
      (.version = $v | .url = $u | .hash = $h)
      | if $d == "" then del(.npmDepsHash) else .npmDepsHash = $d end
    else . end)' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
  echo "$tool/$name -> $version" >&2
}

case "${1-}" in
  --list) outdated | jq -R . | jq -sc . ;;
  --all) for entry in $(outdated); do pin "$entry"; done ;; # listed up front, since pin rewrites the file being scanned
  */*) pin "$1" ;;
  *) sed -n '2,10p' "$0" >&2; exit 2 ;;
esac
