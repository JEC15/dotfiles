 #!/usr/bin/env sh

! command -v swaymsg >/dev/null && {
  printf "%s\n" "Could not find command: swaymsg," >&2
  exit 1
}

! command -v jq >/dev/null && {
  printf "%s\n" "Could not find command: jq." >&2
  exit 1
}
 
! command -v slurp >/dev/null && {
  printf "%s\n" "Could not find command: slurp." >&2
  exit 1
}
 
! command -v wf-recorder >/dev/null && {
  printf "%s\n" "Could not find command: wf-recorder." >&2
  exit 1
}

_selection=$(swaymsg -t get_tree |
  jq -r '
  .. |
  select(.pid? and .visible?) |
  "\(.rect.x + .window_rect.x)," +
  "\(.rect.y + .window_rect.y) " +
  "\(.window_rect.width)x" +
  "\(.window_rect.height)"
' | slurp 2> /dev/null)

[ -n "$_selection" ] &&
wf-recorder -g "$_selection" \
-r 60 \
-c libx264rgb \
-p preset=ultrafast \
-p crf=18 \
-p tune=zerolatency \
--audio=alsa_output.pci-0000_00_1b.0.pro-output-0.monitor \
--file="$HOME"/recording_with_audio.mp4 \
-y
