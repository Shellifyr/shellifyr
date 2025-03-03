#/bin/sh

# Variables
GITHUB_REPO="https://github.com/Shellifyr/shellifyr.git"

# Shell Development Category Defining
STABLE_SHELLS=()
WIP_SHELLS=("bash zsh")

function _get_shell_category_color {
  local shell_name=$1
  if [[ "$STABLE_SHELLS" =~ (^|[[:space:]])$shell_name([[:space:]]|$) ]]; then
    printf '%s' "$GREEN"
  elif [[ "$WIP_SHELLS" =~ (^|[[:space:]])$shell_name([[:space:]]|$) ]]; then
    printf '%s' "$YELLOW"
  else
    printf '%s' "$RED"
  fi 
}

function _shellifyr_install_banner {
  printf '%s' "$GREEN"
  printf 'Your shell is now SHELLYFIED!'
  printf '%s\n' "$NORMAL"
}

function _shellifyr_install_main {
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

  # Only enable exit-on-error after the non-critical color error stuff
  # Which may fail in systems that lack tpuf

  set -e 

  printf "%sCloning Shellifyr's repository...%s\n" "$BLUE" "$NORMAL"
  #if type -P git &>/dev/null; then
  #  git clone $GITHUB_REPO ~/.shellifyr
  #else
  #  printf "%s%s" "$RED" "$BOLD"
  #  printf "FATAL: You don't have git installed in your system."
  #  printf "%s\n" "$NORMAL"
  #  exit
  #fi

  # Display a choice input for the user to select the desired shell to apply Shellifyr.
  printf "%sGetting the user's shells installed in the system...%s\n" "$BLUE" "$NORMAL"
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
      "$GREEN") SORTED_SHELLS+=("1 $shell") ;;
      "$YELLOW") SORTED_SHELLS+=("2 $shell") ;;
      "$RED") SORTED_SHELLS+=("3 $shell") ;;
    esac
  done
  
  SORTED_SHELLS=($(printf "%s\n" "${SORTED_SHELLS[@]}" | sort | awk '{print $2}'))

  for i in "${!SORTED_SHELLS[@]}"; do
    shell_name="${SORTED_SHELLS[$i]}"
    _get_shell_category_color "$shell_name"
    echo "[$i] $shell_name"
  done
  printf '%s\n' "$NORMAL"

  # Ask user input
  while true; do 
    printf '%s' "$BLUE"
    read -rp "Select the shell number to apply Shellifyr: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 0 && choice < ${#SORTED_SHELLS[@]})); then 
      selected_shell="${SORTED_SHELLS[$choice]}"
      break
    else
      printf '%s%s' "$RED" "Invalid option. Please insert "   
      printf '%s%s' "$BOLD" "one of the shell numbers available above.\n"
      printf '%s' "$NORMAL"
    fi
  done
  printf '%s' "$NORMAL"

  _shellifyr_install_banner
}

_shellifyr_install_main
