#!/bin/sh

focused_workspace_name=$(swaymsg -r -t get_workspaces \
| jq -r '.[]
| select(.focused==true)
| .name')

# Focus back to the workspace we were in, since clicking
# on the waybar menu will steal focus
swaymsg workspace "$focused_workspace_name"

focused_window=$(swaymsg -t get_tree \
| jq --arg fwn "$focused_workspace_name" 'recurse(.nodes[]?)
| select(.type=="workspace" and .name==$fwn)
| first(recurse(.nodes[]?, .floating_nodes[]?)
| select(.focused==true and (.type=="con" or .type=="floating_con")))')

if [ "$1" = "move_to_scratchpad" ]; then
  swaymsg [con_id="$(printf "%s" "$focused_window" | jq -r '.id')"] move scratchpad

elif [ "$1" = "kill_window" ]; then
  swaymsg [con_id="$(printf "%s" "$focused_window" | jq -r '.id')"] kill

elif [ "$1" = "toggle_float" ]; then
  swaymsg [con_id="$(printf "%s" "$focused_window" | jq -r '.id')"] floating toggle

elif [ "$1" = "send_to_workspace" ]; then
  if [ "$2" -gt 0 ] && [ "$2" -lt 11 ]; then
    swaymsg [con_id="$(printf "%s" "$focused_window" | jq -r '.id')"] move container to workspace number "$2"
  fi

elif [ "$1" = "toggle_border" ]; then
  border=$(printf "%s" "$focused_window" | jq -r '.border')

  if [ "$border" = "pixel" ]; then
    swaymsg [con_id="$(printf "%s" "$focused_window" | jq -r '.id')"] titlebar_border_thickness 4, border normal 6
  else
    swaymsg [con_id="$(printf "%s" "$focused_window" | jq -r '.id')"] titlebar_border_thickness 1, border pixel 1
  fi

else
  printf "%s\n" "$focused_workspace_name"
fi
