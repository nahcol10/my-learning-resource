# ~/.bashrc
[[ -f /etc/bashrc ]] && . /etc/bashrc
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && PATH="$HOME/.local/bin:$HOME/bin:$PATH"

shopt -s checkwinsize autocd histappend cdspell extglob
stty -ixon
HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T '
PROMPT_DIRTRIM=3
export EDITOR=vim

[[ -f /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion

bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'set bell-style none'

alias ls='ls --color=auto'
alias ll='ls -lah'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias k='kubectl'
alias tf='terraform'
alias g='git'
alias dc='docker compose'

__prompt() {
  local p="" g=""
  [[ -n "$VIRTUAL_ENV" ]] && p="\[\e[35m\](${VIRTUAL_ENV##*/})\[\e[0m\] "
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local b=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    local s="\[\e[32m\]✓"
    git diff --quiet HEAD -- 2>/dev/null || s="\[\e[31m\]✦"
    g=" \[\e[33m\]${b}${s}\[\e[0m\]"
  fi
  PS1="${p}\[\e[35m\]\h\[\e[0m\]:\[\e[36m\]\w\[\e[0m\]${g}\n\[\e[33m\]❯\[\e[0m\] "
}
PROMPT_COMMAND=__prompt
