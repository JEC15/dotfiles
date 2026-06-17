#!/usr/bin/env sh

# Start an application in its own Cgroup to avoid a single memory-hungry service
# taking the entire Sway session down with it, since systemd-oomd tracks resource
# usage by and kills entire Cgroups at once, not processes.
# https://wiki.archlinux.org/title/Sway#Working_with_systemd-oomd

# Applications run this way should appear as .scope
# when checked with "systemd-cgls -u user.slice"

exec systemd-run --user --ignore-failure --scope --unit "app-$1-$(uuidgen)" -- "$@"
