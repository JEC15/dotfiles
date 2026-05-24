#!/bin/sh

pidof -x wvkbd-deskintl > /dev/null 2>&1 &&
 printf "{ \"text\": \"\", \"tooltip\": \"%s\" }" "$(wvkbd-deskintl -v)" ||
  printf "{ \"text\": \"X\", \"tooltip\": \"wvkbd not running\" }"


# Format for embedding directly in the waybar config
# [ \"$(pidof -x wvkbd-deskintl)\" ] && printf \"{ \\\"text\\\": \\\"\\\", \\\"tooltip\\\": \\\"%s\\\" }\" \"$(wvkbd-deskintl -v)\" || printf \"{ \\\"text\\\": \\\"X\\\", \\\"tooltip\\\": \\\"wvkbd not running\\\" }\"
