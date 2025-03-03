# exporting shellifyr's home dir
export SHELLIFYR_HOME="$HOME/.shellifyr"

# path to some config files
CONFIG_FILE="$HOME/.shellifyrrc"
PLUGINS_DIR="$SHELLIFYR_HOME/plugins"

CURRENT_SHELL=$(basename "$SHELL")

# Set and use colors, but only if the are supported by the terminal.
number_colors_supported=
if type -P tput &>/dev/null; then
  number_colors_supported=$(tput colors 2>/dev/null || tput Co 2>/dev/null || echo -1)
fi 

RED=
GREEN=
YELLOW=
BLUE=
BOLD=
NORMAL=
if [[ -t 1 && $number_colors_supported && $number_colors_supported -ge 8 ]]; then
  RED=$(tput setaf 1 2>/dev/null || tput AF 1 2>/dev/null)
  GREEN=$(tput setaf 2 2>/dev/null || tput AF 2 2>/dev/null)
  YELLOW=$(tput setaf 3 2>/dev/null || tput AF 3 2>/dev/null)
  BLUE=$(tput setaf 4 2>/dev/null || tput AF 4 2>/dev/null)
  BOLD=$(tput bold 2>/dev/null || tput md 2>/dev/null)
  NORMAL=$(tput sgr0 2>/dev/null || tput me 2>/dev/null)
fi

# Checks if the config file exists
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
  if [[ $DEBUG_MODE == true ]]; then
    printf '%s%s' "$BLUE" "DEBUG: sourced '$CONFIG_FILE'."
    printf '%s\n' "$NORMAL"
  fi
else
  printf '%s%s%s' "$RED" "$BOLD" "FATAL: .shellifyrrc not found."
  exit 1
fi 

# Loads active plugins
for plugin in "${PLUGINS[@]}"; do 
  # Extracts the compatibility available
  COMPATIBILITY=$(awk -F ': ' '/^# Shell:/ {print $2}' "$CONFIG_FILE")

  # If the plugin doesn't specify compatibility, it assumes it is.
  PLUGIN_FILE="$PLUGINS_DIR/$plugin/$plugin.sh"
  if [[ -f "$PLUGIN_FILE" ]]; then
    if [[ -z "$COMPATIBILITY" || "$COMPATIBILITY" == *"$CURRENT_SHELL"* ]]; then 
      if [[ $DEBUG_MODE == true ]]; then
        printf '%s%s' "$BLUE" "DEBUG: loading '$plugin' plugin..."
        printf '%s\n' "$NORMAL"
      fi
      source "$PLUGIN_FILE"
      if [[ $DEBUG_MODE == true ]]; then
        printf '%s%s' "$BLUE" "DEBUG: loaded '$plugin' plugin."
        printf '%s\n' "$NORMAL"
      fi
    else 
      printf '%s%s%s' "$YELLOW" "$BOLD" "Plugin '$plugin' not compatible with $CURRENT_SELL (only with: $COMPATIBILITY)."
      printf '%s\n' "$NORMAL"
    fi
  else
    printf '%s%s%s' "$YELLOW" "$BOLD" "Plugin not found: $plugin"
    printf '%s\n' "$NORMAL"
  fi 
done
