#!bin/sh

# github repo
GITHUB_REPO="https://github.com/Shellifyr/shellifyr.git"

_fmt_info() {
  printf 'INFO (UPDATE): %s' "$*" 
  printf '%s\n' "$FMT_RESET"
}

_fmt_error() {
  printf 'ERROR (UPDATE): %s' "$*" 
  printf '%s\n' "$FMT_RESET"
}

_fmt_fatal() {
  printf 'FATAL (UPDATE): %s' "$*" 
  printf '%s\n' "$FMT_RESET"
}

# function to update shellifyr
update_shellifyr() {
  _fmt_info "Checking if shellifyr is installed..."

  # checks if the dir exists
  if [ -d "$SHELLIFYR_HOME" ]; then
    _fmt_info "Directory found. Proceeding with the update..."

    # changes to shellifyr dir and pulls the repository
    cd "$SHELLIFYR_HOME" || exit
    git pull origin main &>/dev/null

    _fmt_info "Shellifyr successfully updated to the latest version!"
    exit 1
  else 
    _fmt_error "Directory not found. Checking if SHELLIFYR_HOME environment variable is set..."

    if [ -z "$SHELLIFYR_HOME" ]; then
      _fmt_fatal "SHELLIFYR_HOME is set, but it isn't a detectable directory. Is the environment variable correctly set?"
      exit 1
    fi 

    _fmt_fatal "SHELLIFYR_HOME is not set or the directory wasn't found. Is Shellifyr correctly installed?"
    exit 1
  fi
}

update_shellifyr
