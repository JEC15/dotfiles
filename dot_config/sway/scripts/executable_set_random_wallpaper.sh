#!/bin/sh

pidof swaybg >/dev/null 2>&1 && pkill swaybg >/dev/null 2>&1

swaybg -i "$(find ~/Pictures/wallpapers -type f | shuf -n 1)" &
