# exporting shellifyr's home dir
export SHELLIFYR_HOME="$HOME/.shellifyr"

# path to some config files
CONFIG_FILE="$HOME/.shellifyrrc"
PLUGINS_DIR="$SHELLIFYR_HOME/plugins"
THEMES_DIR="$SHELLIFYR_HOME/themes"

# Current shell name
CURRENT_SHELL="zsh"

# The [ -t 1 ] check only works when the function is not called from
# a subshell (like in `$(...)` or `(...)`, so this hack redefines the
# function at the top level to always return false when stdout is not
# a tty.
if [ -t 1 ]; then
  is_tty() {
    true
  }
else
  is_tty() {
    false
  }
fi

# Set and use colors, but only if the are supported by the terminal.
function _supports_truecolor {
  case "$COLORTERM" in
  truecolor|24bit) return 0 ;;
  esac

  case "$TERM" in
  iterm           |\
  tmux-truecolor  |\
  linux-truecolor |\
  xterm-truecolor |\
  screen-truecolor) return 0 ;;
  esac

  return 1
}

function _setup_color {
  # Only use colors if connected to a terminal
  if ! is_tty; then
    FMT_RAINBOW=""
    FMT_RED=""
    FMT_GREEN=""
    FMT_YELLOW=""
    FMT_BLUE=""
    FMT_BOLD=""
    FMT_RESET=""
    return
  fi

  if _supports_truecolor; then
    FMT_RAINBOW="
      $(printf '\033[38;2;255;0;0m')
      $(printf '\033[38;2;255;97;0m')
      $(printf '\033[38;2;247;255;0m')
      $(printf '\033[38;2;0;255;30m')
      $(printf '\033[38;2;77;0;255m')
      $(printf '\033[38;2;168;0;255m')
      $(printf '\033[38;2;245;0;172m')
    "
  else
    FMT_RAINBOW="
      $(printf '\033[38;5;196m')
      $(printf '\033[38;5;202m')
      $(printf '\033[38;5;226m')
      $(printf '\033[38;5;082m')
      $(printf '\033[38;5;021m')
      $(printf '\033[38;5;093m')
      $(printf '\033[38;5;163m')
    "
  fi

  FMT_RED=$(printf '\033[31m')
  FMT_GREEN=$(printf '\033[32m')
  FMT_YELLOW=$(printf '\033[33m')
  FMT_BLUE=$(printf '\033[34m')
  FMT_BOLD=$(printf '\033[1m')
  FMT_RESET=$(printf '\033[0m')
}

_setup_color

# Checks if the config file exists
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
  if [[ $DEBUG_MODE == true ]]; then
    printf '%s%s' "$FMT_BLUE" "DEBUG: sourced '$CONFIG_FILE'."
    printf '%s\n' "$FMT_RESET"
  fi
else
  printf '%s%s%s' "$FMT_RED" "$FMT_BOLD" "FATAL: .shellifyrrc not found."
fi 

# Loads active plugins
for plugin in "${PLUGINS[@]}"; do 
  # If the plugin doesn't specify compatibility, it assumes it is.
  PLUGIN_FILE="$PLUGINS_DIR/$plugin/$plugin.sh"

  if [[ -f "$PLUGIN_FILE" ]]; then
    # Extracts the compatibility available
    COMPATIBILITY=$(awk -F ': ' '/^# Shell:/ {print $2}' "$PLUGIN_FILE")
    if [[ -z "$COMPATIBILITY" || "$COMPATIBILITY" == *"$CURRENT_SHELL"* ]]; then 
      if [[ $DEBUG_MODE == true ]]; then
        printf '%s%s' "$FMT_BLUE" "DEBUG: loading '$plugin' plugin..."
        printf '%s\n' "$FMT_RESET"
      fi
      source "$PLUGIN_FILE"
      if [[ $DEBUG_MODE == true ]]; then
        printf '%s%s' "$FMT_BLUE" "DEBUG: loaded '$plugin' plugin."
        printf '%s\n' "$FMT_RESET"
      fi
    else 
      printf '%s%s%s' "$FMT_YELLOW" "$FMT_BOLD" "Plugin '$plugin' not compatible with $CURRENT_SHELL (only with: $COMPATIBILITY)."
      printf '%s\n' "$FMT_RESET"
    fi
  else
    printf '%s%s%s' "$FMT_YELLOW" "$FMT_BOLD" "Plugin not found: $plugin"
    printf '%s\n' "$FMT_RESET"
  fi 
done

# Load active theme
THEME_FILE="$SHELLIFYR_HOME/themes/$SHYR_THEME/$SHYR_THEME.theme"

if [[ -f "$THEME_FILE" ]]; then
  # Extracts the compatibility available
  COMPATIBILITY=$(awk -F ': ' '/^# Shell:/ {print $2}' "$THEME_FILE")

  if [[ -z "$COMPATIBILITY" || "$COMPATIBILITY" == *"$CURRENT_SHELL"* ]]; then 
    if [[ $DEBUG_MODE == true ]]; then 
      printf '%s%s' "$FMT_BLUE" "DEBUG: '$SHYR_THEME' loading."
      printf '%s\n' "$FMT_RESET"
    fi
    source "$THEME_FILE"

    # Define Prompt
    if [[ -n "$THEME_PROMPT" ]]; then
      export PS1="$THEME_PROMPT"
    fi

    if [[ $DEBUG_MODE == true ]]; then 
      printf '%s%s' "$FMT_BLUE" "DEBUG: '$SHYR_THEME' theme successfully loaded."
      printf '%s\n' "$FMT_RESET"
    fi
  else 
    printf '%s%s%s' "$FMT_YELLOW" "$FMT_BOLD" "Theme '$SHYR_THEME' not compatible with $CURRENT_SHELL (only with: $COMPATIBILITY)."
    printf '%s\n' "$FMT_RESET"
  fi
else
  printf '%s%s' "$FMT_RED" "FATAL: '$SHYR_THEME' theme not found."
fi
