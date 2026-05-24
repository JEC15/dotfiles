#!/bin/sh

[ $# -lt 1 ] &&
 printf "%s\n" "Missing argument. Valid arguments are 3500, 4000, and 5000." &&
  exit

pidof -x gammastep > /dev/null 2>&1
__is_running=$?

case "$1" in
  3500)
    [ $__is_running -eq 0 ] && pkill -x gammastep > /dev/null 2>&1
    gammastep -O 3500 > /dev/null 2>&1 &
    exit
  ;;
  4000)
    [ $__is_running -eq 0 ] && pkill -x gammastep > /dev/null 2>&1
    gammastep -O 4000 > /dev/null 2>&1 &
    exit
  ;;
  5000)
    [ $__is_running -eq 0 ] && pkill -x gammastep > /dev/null 2>&1
    gammastep -O 5000 > /dev/null 2>&1 &
    exit
  ;;
  6500)
    [ $__is_running -eq 0 ] && pkill -x gammastep > /dev/null 2>&1
    exit
  ;;
  *)
    printf "%s\n" "Invalid argument. Valid arguments are 3500, 4000, and 5000."
    exit
  ;;
esac

# Format for embedding directly in the wayber config
# pidof -x gammastep > /dev/null 2>&1 && pkill -x gammastep > /dev/null 2>&1; { gammastep -O 3500 & } > /dev/null 2>&1; pkill -SIGRTMIN+6 waybar
