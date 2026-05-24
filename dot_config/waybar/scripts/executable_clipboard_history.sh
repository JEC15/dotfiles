#!/bin/env sh

cliphist list \
  | fuzzel -d -a top-right -w 60 --placeholder="Clipboard" \
  -b 1d2021ff -t d4be98ff -s d4be98ff --prompt-color=d4be98ff \
  --input-color=d4be98ff -S 1d2021ff -B 0 \
  | cliphist decode \
  | wl-copy
