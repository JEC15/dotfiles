#!/bin/bash

! command -v rclone >/dev/null && {
  printf "%s\n" "Could not find command: rclone." >&2
  exit 1
}

! command -v fzf >/dev/null && {
  printf "%s\n" "Could not find command: fzf." >&2
  exit 1
}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
# No Color
NC='\033[0m'

MOUNT_BASE="${HOME}/GoogleDrive"
LOG_DIR="${HOME}/rclone-logs"

mkdir -p "$LOG_DIR"

get_all_remotes() {
    rclone listremotes --quiet | sed 's/:$//'
}

is_mounted() {
    local remote="$1"
    mountpoint -q "${MOUNT_BASE}-${remote}" 2>/dev/null
}

mount_remote() {
    local remote="$1"
    local mount_point="${MOUNT_BASE}-${remote}"
    local log_file="${LOG_DIR}/rclone-${remote}.log"

    echo -e "${BLUE}→ Mounting ${YELLOW}${remote}${BLUE} at ${mount_point}...${NC}"
    mkdir -p "$mount_point"

    if /usr/bin/rclone mount "${remote}:" "$mount_point" \
        --daemon \
        --vfs-cache-mode writes \
        --dir-cache-time 72h \
        --poll-interval 10m \
        --vfs-read-chunk-size 128M \
        --vfs-read-chunk-size-limit 2G \
        --buffer-size 16M \
        --log-file "$log_file" \
        --log-level INFO; then

        sleep 2
        if mountpoint -q "$mount_point"; then
            echo -e "${GREEN}✓ Successfully mounted ${remote}${NC}"
            echo -e "  → Location: ${mount_point}"
            return 0
        else
            echo -e "${RED}✗ Mount verification failed${NC}" >&2
            return 1
        fi
    else
        echo -e "${RED}✗ Failed to mount${NC}" >&2
        return 1
    fi
}

unmount_remote() {
    local remote="$1"
    local mount_point="${MOUNT_BASE}-${remote}"

    if ! mountpoint -q "$mount_point" 2>/dev/null; then
        echo -e "${YELLOW}⚠ ${remote} is not mounted${NC}"
        return 0
    fi

    echo -e "${BLUE}→ Unmounting ${YELLOW}${remote}${BLUE}...${NC}"
    if fusermount -uz "$mount_point" 2>/dev/null; then
        echo -e "${GREEN}✓ Unmounted${NC}"
        rmdir "$mount_point" 2>/dev/null
        return 0
    else
        echo -e "${RED}✗ Unmount failed${NC}" >&2
        return 1
    fi
}

mount_all() {
    local all_remotes=$(get_all_remotes)
    local any_mounted=false
    
    while read -r remote; do
        [ -z "$remote" ] && continue
        if ! is_mounted "$remote"; then
            mount_remote "$remote"
            any_mounted=true
        fi
    done <<< "$all_remotes"
    
    if [ "$any_mounted" = false ]; then
        echo -e "${YELLOW}All remotes were already mounted${NC}"
    fi
}

unmount_all() {
    local any_unmounted=false
    for mp in "$MOUNT_BASE"-*; do
        if [ -d "$mp" ] && mountpoint -q "$mp"; then
            local remote=$(basename "$mp" | sed "s/^${MOUNT_BASE##*/}-//")
            unmount_remote "$remote"
            any_unmounted=true
        fi
    done
    
    if [ "$any_unmounted" = false ]; then
        echo -e "${YELLOW}No remotes were mounted${NC}"
    fi
}

# This serves no real purpose now, remove it
show_mounted() {
    local mounted=()
    for mp in "$MOUNT_BASE"-*; do
        if [ -d "$mp" ] && mountpoint -q "$mp"; then
            local remote=$(basename "$mp" | sed "s/^${MOUNT_BASE##*/}-//")
            mounted+=("$remote")
        fi
    done

    if [ ${#mounted[@]} -eq 0 ]; then
        echo -e "${YELLOW}No remotes currently mounted${NC}"
    else
        echo -e "${GREEN}Currently mounted:${NC}"
        printf '  → %s\n' "${mounted[@]}"
    fi
}

# Main interactive menu – Two field format
interactive_menu() {
    if ! command -v fzf &>/dev/null; then
        echo -e "${RED}Error: fzf not installed. Run: sudo pacman -S fzf${NC}"
        exit 1
    fi

    while true; do
        local items=()
        local all_remotes=$(get_all_remotes)

        # Add mounted remotes (UNMOUNT action)
        while read -r remote; do
            [ -z "$remote" ] && continue
            if is_mounted "$remote"; then
                items+=("UNMOUNT|✓ $remote")
            fi
        done <<< "$all_remotes"

        # Add unmounted remotes (MOUNT action)
        while read -r remote; do
            [ -z "$remote" ] && continue
            if ! is_mounted "$remote"; then
                items+=("MOUNT|  $remote")
            fi
        done <<< "$all_remotes"

        if [ -z "$all_remotes" ]; then
            items+=("INFO|No remotes configured in rclone")
        fi

        # Separator and actions
        items+=("SEP|────────────────────────────")
        items+=("ACTION|Mount all unmounted remotes")
        items+=("ACTION|Unmount all mounted remotes")
        items+=("ACTION|Show mounted remotes (info)")
        items+=("ACTION|Quit")

        # Display with fzf – show only the part after |
        local selected=$(printf "%s\n" "${items[@]}" | fzf \
            --delimiter='|' \
            --with-nth=2 \
            --prompt="Select to mount/unmount > " \
            --header="✓ = mounted (select to unmount) | unmounted (select to mount) | Esc to quit" \
            --height=20 \
            --reverse \
            --border \
            --info=inline \
            --color="fg:white,fg+:green,hl:yellow,header:blue")

        [ -z "$selected" ] && echo -e "${GREEN}Goodbye!${NC}" && exit 0

        # Parse: first field is type, second field is the value/display
        local type="${selected%%|*}"
        local data="${selected#*|}"

        case "$type" in
            MOUNT)
                # data looks like "  remote_name" – strip leading spaces
                local remote="${data##  }"
                mount_remote "$remote"
                echo
                read -p "Press Enter to continue..."
                ;;
            UNMOUNT)
                # data looks like "✓ remote_name" – strip "✓ " prefix
                local remote="${data#✓ }"
                unmount_remote "$remote"
                echo
                read -p "Press Enter to continue..."
                ;;
            ACTION)
                case "$data" in
                    "Mount all unmounted remotes")
                        mount_all
                        echo
                        read -p "Press Enter to continue..."
                        ;;
                    "Unmount all mounted remotes")
                        unmount_all
                        echo
                        read -p "Press Enter to continue..."
                        ;;
                    "Show mounted remotes (info)")
                        show_mounted
                        echo
                        read -p "Press Enter to continue..."
                        ;;
                    "Quit")
                        echo -e "${GREEN}Bye.${NC}"
                        exit 0
                        ;;
                esac
                ;;
            INFO|SEP)
                # Do nothing, just loop again
                continue
                ;;
        esac
    done
}

# Command line parsing
case "${1:-interactive}" in
    interactive|i|"")
        interactive_menu
        ;;
    mount|m)
        [ -z "$2" ] && echo "Usage: $0 mount <remote_name>" && exit 1
        mount_remote "$2"
        ;;
    unmount|u)
        [ -z "$2" ] && echo "Usage: $0 unmount <remote_name>" && exit 1
        unmount_remote "$2"
        ;;
    mount-all|ma)
        mount_all
        ;;
    unmount-all|ua)
        unmount_all
        ;;
    list|l)
        show_mounted
        ;;
    help|h|--help|-h)
        cat << EOF
Usage: $0 [COMMAND]

Commands:
  (no args)          Interactive menu with combined mount/unmount view
  interactive, i     Same as above
  mount, m <remote>  Mount a specific remote
  unmount, u <remote> Unmount a specific remote
  mount-all, ma      Mount all unmounted remotes
  unmount-all, ua    Unmount all mounted remotes
  list, l            List mounted remotes
  help, h            Show this help

Examples:
  $0
  $0 mount gdrive-personal
  $0 unmount gdrive-work
  $0 mount-all
  $0 unmount-all
EOF
        ;;
    *)
        echo "Unknown command: $1"
        echo "Run '$0 help' for usage"
        exit 1
        ;;
esac
