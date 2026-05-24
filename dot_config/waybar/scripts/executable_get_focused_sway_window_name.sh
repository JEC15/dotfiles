#!/bin/sh

! command -v swaymsg >/dev/null && {
  printf "%s\n" "Could not find command: swaymsg" >&2
  exit 1
}

! command -v jq >/dev/null && {
  printf "%s\n" "Could not find command: jq" >&2
  exit 1
}

tmpdir=$(mktemp -d /tmp/sway-ipc.XXXXXX) || {
  printf "%s\n" "Failed to create temp dir" >&2
  exit 1
}

fifo="$tmpdir/fifo"

mkfifo "$fifo" || {
  printf "%s\n" "Failed to create FIFO" >&2
  rm -rf "$tmpdir"
  exit 1
}

cleanup() {
  [ -n "$swaymsg_pid" ] && kill "$swaymsg_pid" 2>/dev/null
  rm -rf "$tmpdir"
  exit
}

trap cleanup INT TERM HUP EXIT

get_focused_workspace() {
  workspace_id=$(swaymsg -r -t get_workspaces \
  | jq -r '.[]
  | select(.focused==true) | .id')

  swaymsg -t get_tree \
  | jq --arg wid "$workspace_id" 'first(recurse(.nodes[]?)
  | select(.id==($wid | tonumber)))'
}

get_focused_window_name() {
  # Use printf so we can emit an empty string for an empty workspace
  # which we can then set to be hidden in waybar config
  printf "%s\n" "$(echo "$1" \
  | jq -r 'first(recurse(.nodes[]?, .floating_nodes[]?)
  | select(.focused==true and (.type=="con" or .type=="floating_con"))
  | .name)')"
}

swaymsg -m -t subscribe '["window", "workspace"]' > "$fifo" &
swaymsg_pid=$!

current_workspace=$(get_focused_workspace)

get_focused_window_name "$current_workspace"

while read -r event <&3; do
  case "$event" in
    *'"change": "init"'*|*'"change": "new"'*)
      current_workspace=$(get_focused_workspace)
    ;;
    *'"change": "focus"'*)
      current_workspace=$(get_focused_workspace)
    # echo "focus b4 check"
      # printf "%s\n" "$event" | jq -e 'has("current")' >/dev/null \
      # && current_workspace=$(printf "%s\n" "$event" | jq '.current') \
      # && ! printf "%s\n" "$event" \
      #   | jq -e 'isempty(.current.nodes[],
      #                     .current.floating_nodes[])' >/dev/null \
      # && continue
      printf "%s\n" "$event" | jq -e 'has("current")
         and (isempty(.current.nodes[],
                      .current.floating_nodes[]) | not)' >/dev/null \
      && continue
# echo "fcous after check"
      get_focused_window_name "$current_workspace"
    ;;
    *'"change": "title"'*)
      current_workspace=$(get_focused_workspace)
      ! printf "%s\n" "$event" | jq -e '.container.focused' >/dev/null \
      && continue

      get_focused_window_name "$current_workspace"
    ;;
    *'"change": "close"'*|*'"change": "move"'*)
      current_workspace=$(get_focused_workspace)
      ! printf "%s\n" "$current_workspace" \
      | jq -e 'isempty(.nodes[], .floating_nodes[])' >/dev/null \
      && continue

      get_focused_window_name "$current_workspace"
    ;;
  esac
done 3<"$fifo"

# The script should never terminate normally, but just in case
cleanup
