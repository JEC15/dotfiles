#!/bin/sh

max_workspaces=$(swaymsg -p -t get_config \
  | grep -c 'bindsym $mod+[0-9] workspace number [0-9]')

occupied_workspaces=$(swaymsg -p -t get_workspaces \
  | grep -c "Workspace ")

[ "$max_workspaces" -eq "$occupied_workspaces" ] && exit

focused_workspace=$(swaymsg -p -t get_workspaces \
  | grep "Workspace.*(focused)" \
  | cut -d ' ' -f 2)

i=$focused_workspace
while true;
  do
    [ "$i" -lt "$max_workspaces" ] && i=$((i + 1)) || i=1
    [ -z "$(swaymsg -p -t get_workspaces \
      | grep "Workspace $i ")" ] && break
  done

swaymsg workspace number "$i"

