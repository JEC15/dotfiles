#!/bin/sh

! command -v gammastep >/dev/null && {
  printf "{\"alt\": \"not_installed\", \"tooltip\": \"gammastep not installed.\" }"
  exit
}

pidof -x gammastep > /dev/null 2>&1
__is_running=$?

# Script was re-executed without args by waybar's exec, after module was clicked
# and kill signal.was sent.
[ $# -lt 1 ] && {
  [ $__is_running -eq 1 ] && 
  printf "{\"alt\": \"off\", \"tooltip\": \"%s - Not Running\" }" "$(gammastep -V)" ||
  printf "{\"alt\": \"on\", \"tooltip\": \"%sK\" }"\
 "$(gammastep -V) - $(ps -C gammastep -o args= | cut -d ' ' -f 3)"
 }

# Module was clicked. Kill signal needs to be sent to waybar module in config
# so that the icon will update, handled by the lines above..
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
esac
