#!/usr/bin/env sh

# Used for "open terminal here" custom action in Thunar.
# The path to this file needs to be set inside .config/xfce4/helpers.rc as:
#   "TerminalEmulator=<path-to-script>"
# Then the actual custom action command field can be set in Thunar as:
#   "exo-open --working-directory %f --launch TerminalEmulator <args>"

# Don't run if stdin is connected to a terminal.
[ -t 0 ] && {
  echo "This script is meant to be launched from Thunar, not from a terminal."
  exit 1
}

case "$1" in
  '-f')
          /usr/bin/foot --app-id=foot_float -o colors-dark.alpha=0.75
          ;;
     *)
          /usr/bin/foot
          ;;
esac
