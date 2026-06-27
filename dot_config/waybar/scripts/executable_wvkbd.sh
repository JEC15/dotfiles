#!/bin/sh

! command -v wvkbd-deskintl >/dev/null && {
  printf "{\"alt\": \"not_installed\", \"tooltip\": \"wvkbd-deskintl not installed.\" }"
  exit
}

! pidof -x wvkbd-deskintl > /dev/null 2>&1 && {
  wvkbd-deskintl --hidden -L 180 > /dev/null 2>&1 &
    ! pidof -x wvkbd-deskintl > /dev/null 2>&1 && {
    printf "{ \"alt\": \"off\", \"tooltip\": \"wvkbd not running\" }"
    exit
  }
} || printf "{ \"alt\": \"on\", \"tooltip\": \"%s\" }" "$(wvkbd-deskintl -v)"
