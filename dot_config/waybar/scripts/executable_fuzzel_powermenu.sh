#!/bin/sh

selection=$(printf "Reboot\nReload Sway config\nPower Off" \
| fuzzel -d -l 3 -a top-right)

case "$selection" in
  Reboot)
    choice=$(printf "Yes\nNo" \
    | fuzzel -d -l 2 -a top-right --placeholder="Confirm Reboot") 
    [ "$choice" = "Yes" ] && systemctl reboot || exit
    ;;
  "Reload Sway config")
    choice=$(printf "Yes\nNo" \
    | fuzzel -d -l 2 -a top-right --placeholder="Confirm Reload Sway Config")
    [ "$choice" = "Yes" ] && swaymsg reload || exit
    ;;
  "Power Off")
    choice=$(printf "Yes\nNo" \
    | fuzzel -d -l 2 -a top-right --placeholder="Confirm Power Off") 
    [ "$choice" = "Yes" ] && systemctl poweroff || exit
    ;;
esac
