#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIG_SNIPPET_FILE="${SCRIPT_DIR}/tigrc"
VIM_SNIPPET_FILE="${SCRIPT_DIR}/vimrc-snippet.vim"
TIGRC_TARGET="${HOME}/.tigrc"
VIMRC_TARGET="${HOME}/.vimrc"
MARKER_START='>>> gitlens-tui >>>'
MARKER_END='<<< gitlens-tui <<<'

log() {
  printf '[gitlens-tui] %s\n' "$*"
}

die() {
  printf '[gitlens-tui] ERROR: %s\n' "$*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

run_privileged() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
    return
  fi

  if command -v sudo >/dev/null 2>&1; then
    sudo "$@"
    return
  fi

  die "Need root privileges for: $*. Install sudo or run as root."
}

ensure_file_exists() {
  local target="$1"
  if [ ! -e "$target" ]; then
    : > "$target"
  fi
}

upsert_managed_block() {
  local target="$1"
  local source="$2"
  local start_marker="$3"
  local end_marker="$4"
  local tmp_file

  ensure_file_exists "$target"

  if grep -Fq "$start_marker" "$target"; then
    tmp_file="$(mktemp)"

    awk -v start="$start_marker" -v end="$end_marker" -v source="$source" '
      function emit_source(   line) {
        while ((getline line < source) > 0) {
          print line
        }
        close(source)
      }

      {
        if (in_block) {
          if (index($0, end) > 0) {
            in_block = 0
          }
          next
        }

        if (index($0, start) > 0) {
          if (!replaced) {
            emit_source()
            replaced = 1
          }
          in_block = 1
          next
        }

        print
      }
    ' "$target" > "$tmp_file"

    mv "$tmp_file" "$target"
    log "Updated managed block in ${target}."
    return
  fi

  if [ -s "$target" ]; then
    printf '\n' >> "$target"
  fi

  cat "$source" >> "$target"
  log "Inserted managed block in ${target}."
}

install_tig() {
  if command -v tig >/dev/null 2>&1; then
    log 'tig already installed; skipping package install.'
    return
  fi

  if command -v apt-get >/dev/null 2>&1; then
    log 'Installing tig with apt-get.'
    run_privileged apt-get update -y
    run_privileged apt-get install -y tig
    return
  fi

  if command -v dnf >/dev/null 2>&1; then
    log 'Installing tig with dnf.'
    run_privileged dnf install -y tig
    return
  fi

  if command -v pacman >/dev/null 2>&1; then
    log 'Installing tig with pacman.'
    run_privileged pacman -S --noconfirm --needed tig
    return
  fi

  die 'No supported package manager found (apt-get, dnf, pacman).'
}

remove_legacy_managed_aliases() {
  local alias_name
  local legacy_value
  local current_values
  local legacy_value_pattern

  need_cmd git

  while IFS='|' read -r alias_name legacy_value; do
    [ -n "$alias_name" ] || continue

    current_values="$(git config --global --get-all "alias.${alias_name}" || true)"
    if [ -z "$current_values" ]; then
      continue
    fi

    if printf '%s\n' "$current_values" | grep -Fxq "$legacy_value"; then
      legacy_value_pattern="$(printf '%s\n' "$legacy_value" | sed 's/[][(){}.^$*+?|\\]/\\&/g')"
      git config --global --unset-all "alias.${alias_name}" "^${legacy_value_pattern}$"

      if printf '%s\n' "$current_values" | grep -Fvxq "$legacy_value"; then
        log "Removed legacy value from git alias ${alias_name}; custom values kept."
      else
        log "Removed legacy managed git alias ${alias_name}."
      fi
      continue
    fi

    log "Kept custom git alias ${alias_name}."
  done <<'EOF'
st|status -sb
lg|log --graph --decorate --oneline --all
lga|log --graph --decorate --oneline --all --date=short
last|log -1 --stat
amend|commit --amend --no-edit
unstage|restore --staged --
rb|rebase
co|checkout
br|branch
EOF
}

main() {
  [ -f "$TIG_SNIPPET_FILE" ] || die "Missing ${TIG_SNIPPET_FILE}"
  [ -f "$VIM_SNIPPET_FILE" ] || die "Missing ${VIM_SNIPPET_FILE}"

  install_tig
  remove_legacy_managed_aliases
  upsert_managed_block "$TIGRC_TARGET" "$TIG_SNIPPET_FILE" "$MARKER_START" "$MARKER_END"
  upsert_managed_block "$VIMRC_TARGET" "$VIM_SNIPPET_FILE" "$MARKER_START" "$MARKER_END"

  log 'Install complete.'
  log 'Uninstall guidance: remove gitlens-tui marker blocks from ~/.tigrc and ~/.vimrc.'
}

main "$@"
