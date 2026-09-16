#!/usr/bin/env bash
# `rm`/`rmdir` replacement: trashes normally, but removes for real wherever a
# trash bin would be useless or impossible. `$trash_cmd` and `$real_cmd` are
# set by the wrapper (default.nix). Two cases fall back to real removal:
# - Systems whose "/" is rolled back on every boot (an ephemeral root). There
#   is no way to detect that from the filesystem, so it is opt-in: create the
#   marker file below and anything on the root device is removed outright,
#   since its trash bin would not survive the next reboot anyway.
# - Volumes that cannot hold a bin. The freedesktop spec keeps the trash on the
#   file's own volume, so a mount the user cannot write to at its top level has
#   nowhere to put one and trash-put fails instead of deleting.
marker=/etc/ephemeral-root-marker

# Split flags (e.g. -r, -f, -v) from path operands so both branches see them.
flags=()
paths=()
for arg in "$@"; do
  case "$arg" in
  -*) flags+=("$arg") ;;
  *) paths+=("$arg") ;;
  esac
done

if [ "${#paths[@]}" -eq 0 ]; then
  exec "$trash_cmd" "$@"
fi

root_dev=$(stat -c %d /)
home_trash=${XDG_DATA_HOME:-$HOME/.local/share}
home_dev=$(stat -c %d -- "$home_trash" 2>/dev/null || stat -c %d -- "$HOME")

# Whether $1 can actually reach a trash bin.
trashable() {
  local path=$1 topdir dev
  # Leave a missing path to the trash command, so it reports it as usual.
  [ -e "$path" ] || return 0
  dev=$(stat -c %d -- "$path")
  # Doomed with the root dataset at the next rollback.
  if [ -e "$marker" ] && [ "$dev" = "$root_dev" ]; then
    return 1
  fi
  # Same volume as the user's own bin under ~/.local/share/Trash.
  if [ "$dev" = "$home_dev" ]; then
    return 0
  fi
  # Otherwise the bin has to live at the top of the path's own volume, either
  # pre-created as .Trash or creatable as .Trash-$uid.
  topdir=$(stat -c %m -- "$path")
  [ -d "$topdir/.Trash" ] || [ -w "$topdir" ]
}

trash=()
real=()
for p in "${paths[@]}"; do
  if trashable "$p"; then
    trash+=("$p")
  else
    real+=("$p")
  fi
done

status=0
if [ "${#trash[@]}" -gt 0 ]; then
  "$trash_cmd" "${flags[@]}" "${trash[@]}" || status=$?
fi
if [ "${#real[@]}" -gt 0 ]; then
  "$real_cmd" "${flags[@]}" "${real[@]}" || status=$?
fi
exit "$status"
