#!/bin/sh

# IGNORED_BINDIRS=/usr/bin:/usr/bin/core_perl:/usr/bin/site_perl:/usr/bin/vendor_perl

_bindirs=$(echo "$PATH" | sed 's/^/ /;s/$/ /;s/:/ /g')

_ignoredirs=""
[ -n "$IGNORED_BINDIRS" ] && _ignoredirs=$(echo "$IGNORED_BINDIRS" \
  | sed 's/\//\\\//g;s/^/\s\/ /;s/:/ \/ \/\g;\s\/ /g;s/$/ \/ \/\g/')

_lsdirs=$(echo "$_bindirs" | sed "$_ignoredirs" | sed 's/^ \{1,\}//;s/ \{1,\}$//')

# Unquoted _lsdirs so the paths are split by space
_ex=$(find $_lsdirs \( -type f -o -type l \) -print0 \
  | xargs -0 basename -a \
  | sort -u \
  | fuzzel --dmenu --no-sort --counter --match-mode=exact \
  --font="IosevkaTerm Nerd Font Mono" -b 1d2021ff -t d4be98ff \
  -s d4be98ff --prompt-color=d4be98ff --input-color=d4be98ff -S 1d2021ff -B 0)
[ -n "$_ex" ] && exec "$_ex"
