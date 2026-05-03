#!/bin/bash

# ===============================
# .bashrc
# ===============================

# Global config
[[ -f /etc/bashrc ]] && . /etc/bashrc

# PATH
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export PATH

# Extra per-user config snippets
if [[ -d ~/.bashrc.d ]]; then
  for rc in ~/.bashrc.d/*; do [[ -f "$rc" ]] && . "$rc"; done
  unset rc
fi

# ===============================
# ble.sh — load first, attach last
# ===============================
[[ $- == *i* ]] && [[ -f ~/.local/share/blesh/ble.sh ]] && \
  source ~/.local/share/blesh/ble.sh --noattach

# ===============================
# Prompt
# ===============================
__build_prompt() {
  local EXIT_CODE=$?

  local EXIT_INFO=""
  (( EXIT_CODE != 0 )) && EXIT_INFO="\[\033[38;5;204m\][${EXIT_CODE}]\[\033[0m\] "

  local GIT_INFO=""
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local BRANCH STATE
    BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    if [[ -n "$(git status --porcelain 2>/dev/null | head -1)" ]]; then
      STATE="\[\033[38;5;204m\]✦\[\033[0m\]"
    else
      STATE="\[\033[38;5;78m\]✓\[\033[0m\]"
    fi
    GIT_INFO=" \[\033[38;5;222m\]${BRANCH}\[\033[0m\]${STATE}"
  fi

  PS1="${EXIT_INFO}\[\033[38;5;141m\]\u\[\033[0m\]:\[\033[38;5;81m\]\w\[\033[0m\]${GIT_INFO}\n\[\033[38;5;209m\]❯ \[\033[0m\]"
}

PROMPT_COMMAND=__build_prompt

# ===============================
# ble.sh behaviour
# ===============================
if [[ ${BLE_VERSION-} ]]; then
  bleopt complete_auto_delay=80
  bleopt history_share=1
  ble-attach
fi