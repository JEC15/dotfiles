#!/bin/sh

pidof -x gammastep > /dev/null 2>&1 &&
 printf "{\"alt\": \"on\", \"tooltip\": \"%sK\" }"\
 "$(gammastep -V) - $(ps -C gammastep -o args= | cut -d ' ' -f 3)" ||
 printf "{\"alt\": \"off\", \"tooltip\": \"%s - Not Running\" }" "$(gammastep -V)"


# Format for embedding directly in the waybar config file
# { pidof -x gammastep > /dev/null 2>&1 && printf \"{\\\"alt\\\": \\\"on\\\", \\\"tooltip\\\": \\\"%s\\\" }\" \"$(gammastep -V) - $(ps -C gammastep -o args= | cut -d ' ' -f 3)K\"; } || printf \"{\\\"alt\\\": \\\"off\\\", \\\"tooltip\\\": \\\"%s\\\" }\" \"$(gammastep -V) - Not Running\"
