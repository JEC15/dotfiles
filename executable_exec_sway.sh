#!/usr/bin/env sh

export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=sway:wlroots
export XDG_SESSION_DESKTOP=sway:wlroots

export PATH="${PATH}:${HOME}/.local/bin"

export QT_QPA_PLATFORMTHEME=qt6ct

exec sway > /tmp/sway.log 2>&1

