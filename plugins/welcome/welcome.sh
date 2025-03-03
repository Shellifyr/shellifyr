# Plugin: Welcome
# Description: Prints a simple welcome message when the session starts.
# Creator: jappend
# Shell: bash

# Set and use colors, but only if the are supported by the terminal.
local number_colors_supported=
if type -P tput &>/dev/null; then
  number_colors_supported=$(tput colors 2>/dev/null || tput Co 2>/dev/null || echo -1)
fi 

local RED GREEN YELLOW BLUE BOLD NORMAL
if [[ -t 1 && $number_colors_supported && $number_colors_supported -ge 8 ]]; then
  RED=$(tput setaf 1 2>/dev/null || tput AF 1 2>/dev/null)
  GREEN=$(tput setaf 2 2>/dev/null || tput AF 2 2>/dev/null)
  YELLOW=$(tput setaf 3 2>/dev/null || tput AF 3 2>/dev/null)
  BLUE=$(tput setaf 4 2>/dev/null || tput AF 4 2>/dev/null)
  BOLD=$(tput bold 2>/dev/null || tput md 2>/dev/null)
  NORMAL=$(tput sgr0 2>/dev/null || tput me 2>/dev/null)
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  BOLD=""
  NORMAL=""
fi

printf '%s%s' "$BLUE" "Welcome back, "
printf '%s%s' "$BOLD" "$(whoami)!"
printf '%s%s%s' "$NORMAL" "$BLUE" "It's currently $(time)."
printf '%s\n' "$NORMAL"
