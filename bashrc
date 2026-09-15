# ~/.bashrc
[[ -f /etc/bashrc ]] && . /etc/bashrc
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && PATH="$HOME/.local/bin:$HOME/bin:$PATH"

shopt -s checkwinsize autocd histappend cdspell extglob

HISTSIZE=30000
HISTFILESIZE=60000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T '

[[ -f /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion

bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'set skip-completed-text on'
bind 'set bell-style none'

alias ls='ls --color=auto'
alias ll='ls -lah'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

__prompt() {
  local ec=$?
  local p="" g=""
  (( ec )) && p="\[\e[38;5;203m\][$ec]\[\e[0m\] "
  [[ -n "$VIRTUAL_ENV" ]] && p+="\[\e[38;5;183m\](${VIRTUAL_ENV##*/})\[\e[0m\] "
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local b=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    local s="\[\e[38;5;114m\]✓"
    git diff --quiet HEAD -- 2>/dev/null || s="\[\e[38;5;203m\]✦"
    g="\[\e[38;5;178m\]${b}${s}\[\e[0m\] "
  fi
  PS1="${p}\[\e[38;5;141m\]\u\[\e[0m\]:\[\e[38;5;117m\]\w\[\e[0m\] ${g}\n\[\e[38;5;208m\]❯ \[\e[0m\]"
}
PROMPT_COMMAND=__prompt

export LS_COLORS="di=38;5;51:ln=38;5;226:ex=38;5;118:*.py=38;5;45:*.js=38;5;226:*.ts=38;5;226:*.json=38;5;214:*.md=38;5;231:*.html=38;5;207:*.css=38;5;207:*.env=38;5;196:*.log=38;5;248:*.zip=38;5;201:*.tar=38;5;201:*.gz=38;5;201:*.png=38;5;135:*.svg=38;5;135"
