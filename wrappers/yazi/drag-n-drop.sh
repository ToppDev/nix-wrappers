#!/usr/bin/env bash

files=$(dragon-drop -x -T -t -p)
[ -d "$1" ] && target="$1" || target=$(pwd)
[ -z "$files" ] && exit 0

ans=$(zenity --info --width=400 --title "File operation" \
  --text="<big><b>Into: $target</b></big>\n\n$files" \
  --ok-label="Cancel" \
  --extra-button="Link" \
  --extra-button="Move" \
  --extra-button="Copy")

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for f in $files; do
  if [[ "$ans" == "Copy" ]]; then
    cp "$f" "$target"
  elif [[ "$ans" == "Move" ]]; then
    mv "$f" "$target"
  elif [[ "$ans" == "Link" ]]; then
    ln -s "$f" "$target"
  fi
done
IFS=$SAVEIFS
