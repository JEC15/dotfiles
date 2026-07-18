#!/usr/bin/env sh

! command -v wvkbd-deskintl >/dev/null && {
  printf "{\"alt\": \"not_installed\", \"tooltip\": \"wvkbd-deskintl not installed.\" }"
  exit
}

! pidof -x wvkbd-deskintl >/dev/null 2>&1 && {
  wvkbd-deskintl --hidden -L 180 >/dev/null 2>&1 &
  # Check again that wvkbd process is running,instead of checking
  # its exit status, since doing that will give us the exit status
  # of the "&" job control operation .
  # Give waybar a second to start before emitting output, otherwise it
  # will incorrectly report wvkbd as "not running".
  sleep 1
  ! pidof -x wvkbd-deskintl >/dev/null 2>&1 && {
    printf "{ \"alt\": \"off\", \"tooltip\": \"wvkbd not running\" }"
    exit
  }
} || printf "{ \"alt\": \"on\", \"tooltip\": \"%s\" }" "$(wvkbd-deskintl -v)"
