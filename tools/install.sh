#/bin/sh

set -e 

# Variables
GITHUB_REPO="https://github.com/Shellifyr/shellifyr.git"

# Shell Development Category Defining
STABLE_SHELLS=()
WIP_SHELLS=("bash zsh")

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

function _fmt_info {
  printf '%sINFO: %s%s' "${FMT_BOLD}" "${FMT_BLUE}" "$*" 
  printf '%s\n' "$FMT_RESET"
}

function _fmt_error {
  printf '%sERROR: %s%s' "${FMT_BOLD}" "${FMT_YELLOW}" "$*" 
  printf '%s\n' "$FMT_RESET"
}

function _fmt_fatal {
  printf '%sFATAL: %s%s' "${FMT_BOLD}" "${FMT_RED}" "$*" 
  printf '%s\n' "$FMT_RESET"
}

function _clone_repo {
  _fmt_info "Cloning Shellifyr's repository..."
  if type -P git &>/dev/null; then
    git clone $GITHUB_REPO $HOME/.shellifyr &>/dev/null
  else
    _fmt_fatal "You don't have git installed in your system."
    exit 1
  fi
}

function _get_ini_value {
  local section=$1
  local key=$2
  awk -F '=' -v section="$section" -v key="$key" '
    $0 ~ "\\["section"\\]"{flag=1}
    flag && $1 ~ key {print $2; exit}
  ' ~/.shellifyr/shell_paths.ini
}

function _get_shell_category_color {
  local shell_name=$1
  if [[ "$STABLE_SHELLS" =~ (^|[[:space:]])$shell_name([[:space:]]|$) ]]; then
    printf '%s' "${FMT_GREEN}"
  elif [[ "$WIP_SHELLS" =~ (^|[[:space:]])$shell_name([[:space:]]|$) ]]; then
    printf '%s' "${FMT_YELLOW}"
  else
    printf '%s' "${FMT_RED}"
  fi 
}

function _shellifyr_install_banner {
  local shell=$1
  printf '%s%s%s\n' "${FMT_GREEN}" "$shell is now SHELLIFYED!" "${FMT_RESET}"
}

function _shellifyr_install_main {
  _setup_color
  if [[ -d "$HOME/.shellifyr" ]]; then
    printf '%s%s' "${FMT_YELLOW}" "Shellifyr's repository is already installed in your system, would you like to re-install it? [y/N]: " 
    read -r reinstall_choice
    printf '%s\n' "${FMT_RESET}"

    local choice_lower=$(echo $reinstall_choice | tr '[:upper:]' '[:lower:]')

    if [[ $choice_lower == "y" ]]; then
      rm -rf ~/.shellifyr
      _clone_repo
    elif [[ $choice_lower == "n" ]]; then
      _fmt_info "Not reinstalling. Closing..."
      exit 1
    else 
      _fmt_info "Not a valid response. Not reinstalling. Closing..."
      exit 1
    fi
  else 
    _clone_repo
  fi

  # Display a choice input for the user to select the desired shell to apply Shellifyr.
  _fmt_info "Getting the user's shells installed in the system..." 
  declare -A SHELLS_MAP
  UNIQUE_SHELLS=()
  SORTED_SHELLS=()

  for shell in $(awk '!/^#/ {print $NF}' /etc/shells); do 
    name=$(basename "$shell")  
    if [[ -z "${SHELLS_MAP[$name]}" ]]; then
      SHELLS_MAP[$name]=1
      UNIQUE_SHELLS+=("$name")
    fi  
  done

  # SORT THE SHELLS BY DEVELOPMENT STATE
  for shell in "${UNIQUE_SHELLS[@]}"; do 
    color=$(_get_shell_category_color "$shell")
    case "$color" in 
      "${FMT_GREEN}") SORTED_SHELLS+=("1 $shell") ;;
      "${FMT_YELLOW}") SORTED_SHELLS+=("2 $shell") ;;
      "${FMT_RED}") SORTED_SHELLS+=("3 $shell") ;;
    esac
  done
  
  SORTED_SHELLS=($(printf "%s\n" "${SORTED_SHELLS[@]}" | sort | awk '{print $2}'))

  for i in "${!SORTED_SHELLS[@]}"; do
    shell_name="${SORTED_SHELLS[$i]}"
    _get_shell_category_color "$shell_name"
    echo "[$i] $shell_name"
  done
  printf '%s\n' "$FMT_RESET"

  # Ask user input
  while true; do 
    printf '%s%s' "${FMT_BLUE}" 'Select the shell number to apply Shellifyr: '
    printf '%s' "${FMT_RESET}"
    read -r choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 0 && choice < ${#SORTED_SHELLS[@]})); then 
      selected_shell="${SORTED_SHELLS[$choice]}"
      break
    else
      _fmt_error "Invalid option. Please insert one of the shell numbers available above."   
    fi
  done
  printf '%s\n' "$FMT_RESET"
  
  INIT_FILE=$(_get_ini_value "$selected_shell" "init_file")
  INIT_COMMAND=$(_get_ini_value "$selected_shell" "init_command")

  # Verify if the shell is supported
  if [[ -z "$INIT_FILE" || -z "$INIT_COMMAND" ]]; then
    _fmt_fatal "Shell '$selected_shell' not supported or missing configuration. Deleting ~/.shellifyr..." "$NORMAL"
    rm -rf ~/.shellifyr
    exit 1
  fi

  if ! grep -q "$INIT_COMMAND" "$HOME/$INIT_FILE"; then
    echo "$INIT_COMMAND" >> "$HOME/$INIT_FILE"
  fi

  _fmt_info "Generating your .shellifyrc file."
  echo "$(cat $HOME/.shellifyr/templates/.shellifyrrc)" > "$HOME/.shellifyrrc"

  _shellifyr_install_banner $selected_shell
}

_shellifyr_install_main
