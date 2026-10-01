# ~/.bashrc
[[ $- != *i* ]] && return

[[ -f /etc/bashrc ]] && . /etc/bashrc
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && PATH="$HOME/.local/bin:$PATH"

export EDITOR=nvim

# --- Shell & history ---
shopt -s checkwinsize histappend
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups

# --- Readline ---
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'set bell-style none'

# --- Aliases ---
alias ls='ls --color=auto'
alias ll='ls -lah'
alias grep='grep --color=auto'
alias ..='cd ..'
alias g='git'

# --- Prompt ---
# Layout:  [(venv)] user[@host]:~/path branch[*] [↑ahead ↓behind]
#          [exit-code] ❯          (red # for root)
# Truecolor palette. \001/\002 mark non-printing text (same as \[ \]),
# which lets the colors live inside variables.
C_RESET=$'\001\e[0m\002'
C_HOST=$'\001\e[38;2;186;85;211m\002'    # orchid  - user/host, venv
C_PATH=$'\001\e[38;2;64;188;200m\002'      # cyan    - directory, ahead/behind
C_ARROW=$'\001\e[38;2;224;132;56m\002'   # orange  - prompt arrow
C_BRANCH=$'\001\e[38;2;240;200;80m\002'    # yellow  - git branch
C_BAD=$'\001\e[38;2;255;85;85m\002'      # red     - dirty *, errors, root

PROMPT_DIRTRIM=3

# Static parts, computed once at startup.
# Host is shown only over SSH and for root; edit __who to always show it.
__me=${USER:-$LOGNAME}
__who="${C_HOST}${__me}${C_RESET}:" __ch='❯' __ok="${C_ARROW}❯${C_RESET} "
if (( EUID == 0 )); then
  __who="${C_BAD}${__me}@${HOSTNAME%%.*}${C_RESET}:"
  __ch='#' __ok="${C_BAD}# ${C_RESET}"
elif [[ -n $SSH_CONNECTION ]]; then
  __who="${C_HOST}${__me}@${HOSTNAME%%.*}${C_RESET}:"
fi

# PS1 is set once. Branch names live in variables (not in PS1 itself), so a
# hostile branch name like '$(cmd)' is never executed.
PS1='${__venv}${__who}${C_PATH}\w${C_RESET}${__git}\n${__tail}'

__prompt() {
  local rc=$?
  local out br ab a b mark sync
  __venv='' __git=''

  if [[ -n $VIRTUAL_ENV ]]; then
    br=${VIRTUAL_ENV##*/}
    [[ $br == .venv || $br == venv ]] && { br=${VIRTUAL_ENV%/*}; br=${br##*/}; }
    __venv="${C_HOST}(${br})${C_RESET} "
  fi

  # One git call gives branch, dirty state and ahead/behind.
  # -uno skips untracked files (the slow part in big repos).
  if out=$(git --no-optional-locks status --porcelain=v2 --branch -uno 2>/dev/null); then
    br=${out#*branch.head }; br=${br%%$'\n'*}
    [[ $br == '(detached)' ]] && { br=${out#*branch.oid }; br=${br:0:7}; }
    mark='' sync=''
    [[ $out == *$'\n'[!#]* ]] && mark="${C_BAD}*"
    if [[ $out == *'branch.ab '* ]]; then
      ab=${out#*branch.ab }; ab=${ab%%$'\n'*}
      a=${ab%% *} b=${ab##* }
      [[ $a != +0 ]] && sync+=" ↑${a#+}"
      [[ $b != -0 ]] && sync+=" ↓${b#-}"
    fi
    __git=" ${C_BRANCH}${br}${mark}${C_PATH}${sync}${C_RESET}"
  fi

  if (( rc )); then __tail="${C_BAD}${__ch}${C_RESET} "
  else __tail=$__ok
  fi
}
PROMPT_COMMAND=__prompt

