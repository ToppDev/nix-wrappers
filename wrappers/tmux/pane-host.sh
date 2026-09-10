# Prints the host a pane is currently working on: the target of the innermost
# ssh client running below the pane, or the local hostname when there is none.
#   $1 - pid of the pane's shell
#   $2 - local hostname, used as the fallback

pane_pid="${1:-}"
fallback="${2:-}"

if [ -z "$pane_pid" ] || [ ! -d "/proc/$pane_pid" ]; then
  printf '%s\n' "$fallback"
  exit 0
fi

# Snapshot the process table once, then let awk walk the pane's subtree. The
# deepest ssh wins, so a chain of hops reports the host actually sitting in
# front of the user.
ssh_pid=$(ps -eo pid=,ppid=,comm= | awk -v root="$pane_pid" '
  {
    parent[$1] = $2
    comm[$1] = $3
  }
  END {
    best = -1
    for (pid in comm) {
      if (comm[pid] != "ssh") continue

      depth = 0
      p = pid
      while (p != root && (p in parent) && depth < 64) {
        p = parent[p]
        depth++
      }
      if (p != root) continue

      if (depth > best) {
        best = depth
        found = pid
      }
    }
    if (best >= 0) print found
  }
')

# /proc holds the real argv, NUL separated, so options containing spaces stay
# one word — `ps` would have flattened them into something unparseable.
if [ -z "$ssh_pid" ] || [ ! -r "/proc/$ssh_pid/cmdline" ]; then
  printf '%s\n' "$fallback"
  exit 0
fi
mapfile -d '' -t argv < "/proc/$ssh_pid/cmdline"

# Walk the command line and stop at the first non-option word, skipping over
# the options that take a separate argument.
set -- "${argv[@]:1}"
target=""
while [ $# -gt 0 ]; do
  case "$1" in
    -[BbcDEeFIiJLlmOoPpQRSWw])
      if [ $# -lt 2 ]; then break; fi
      shift 2
      ;;
    -*) shift ;;
    *)
      target="$1"
      break
      ;;
  esac
done

if [ -z "$target" ]; then
  printf '%s\n' "$fallback"
  exit 0
fi

target="${target#ssh://}"
target="${target#*@}" # drop the login name
target="${target%%:*}" # drop a uri port
target="${target%%.*}" # keep the short name only
printf '%s\n' "$target"
