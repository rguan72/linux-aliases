export PATH="$(brew --prefix)/opt/python@3.11/libexec/bin:$PATH"
source ~/.aliases

# --- Auto Python venv like Cursor ---
# Activates .venv/ or venv/ on entering a directory; deactivates when leaving.

# Return the path to a project venv if present, else empty.
_pyproj_venv_path() {
  local cand=""
  if [ -d "$PWD/.venv" ]; then
    cand="$PWD/.venv"
  elif [ -d "$PWD/venv" ]; then
    cand="$PWD/venv"
  fi
  # Only accept if it looks like a real venv
  if [ -n "$cand" ] && [ -f "$cand/bin/activate" ]; then
    printf "%s" "$cand"
  fi
}

# Track which venv we auto-activated so we can safely deactivate later.
export __AUTO_VENV_PATH=""

_auto_venv_chpwd() {
  local proj_venv="$(_pyproj_venv_path)"

  # If we have an auto-activated venv and we've left that project, deactivate it.
  if [ -n "$__AUTO_VENV_PATH" ] && [ "$proj_venv" != "$__AUTO_VENV_PATH" ]; then
    # Only deactivate if the currently active venv matches the one we auto-activated
    if [ -n "$VIRTUAL_ENV" ] && [ "$VIRTUAL_ENV" = "$__AUTO_VENV_PATH" ]; then
      # silence shellcheck in bash; harmless in zsh
      deactivate >/dev/null 2>&1
    fi
    export __AUTO_VENV_PATH=""
  fi

  # If there is a project venv here and it's not active, activate it.
  if [ -n "$proj_venv" ] && [ "$VIRTUAL_ENV" != "$proj_venv" ]; then
    # If some other venv is active (manual or from elsewhere), deactivate first.
    if [ -n "$VIRTUAL_ENV" ] && [ "$VIRTUAL_ENV" != "$proj_venv" ]; then
      deactivate >/dev/null 2>&1
    fi
    # shellcheck disable=SC1090
    source "$proj_venv/bin/activate"
    export __AUTO_VENV_PATH="$proj_venv"
  fi
}

# Run on directory changes…
autoload -U add-zsh-hook
add-zsh-hook chpwd _auto_venv_chpwd
# …and on new shells.
_auto_venv_chpwd
# --- end auto venv ---
