#!/usr/bin/env bash
# `rm` replacement: trashes files normally, except on hosts where "/" is an
# ephemeral ZFS dataset that gets rolled back on every boot (marked by
# /etc/ephemeral-root-marker). There, anything still living on that same device
# would lose its trash bin at the next reboot anyway, so it's `rm`'d for real
# instead. Files already inside a persisted directory are unaffected.
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

if [ ! -e "$marker" ] || [ "${#paths[@]}" -eq 0 ]; then
  exec rmtrash "$@"
fi

root_dev=$(stat -c %d /)
ephemeral=()
persisted=()
for p in "${paths[@]}"; do
  if [ -e "$p" ] && [ "$(stat -c %d -- "$p")" = "$root_dev" ]; then
    ephemeral+=("$p")
  else
    persisted+=("$p")
  fi
done

status=0
if [ "${#persisted[@]}" -gt 0 ]; then
  rmtrash "${flags[@]}" "${persisted[@]}" || status=$?
fi
if [ "${#ephemeral[@]}" -gt 0 ]; then
  rm "${flags[@]}" "${ephemeral[@]}" || status=$?
fi
exit "$status"
