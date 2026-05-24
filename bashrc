# ~/.bashrc 

# Source system-wide config
[[ -f /etc/bashrc ]] && . /etc/bashrc

# PATH: Ensure user-local binaries are prioritized
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Shell Options (Built-in, zero overhead)
shopt -s checkwinsize autocd histappend cdspell dirspell checkjobs extglob

# History Configuration
HISTSIZE=30000
HISTFILESIZE=60000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T '
HISTIGNORE="&:[bf]g:exit:reset:clear:cd .."

# Bash Completion (Native & lightweight)
if ! shopt -oq posix; then
  [[ -f /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion
  [[ -f /etc/bash_completion ]] && . /etc/bash_completion
fi

# Readline / Terminal UX Tweaks
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'set skip-completed-text on'
bind 'set bell-style none'
bind '"\C-o": accept-line'  # Force Ctrl+o to execute line (no multiline)

# Minimal, High-Value Aliases
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'

# Lightweight Custom Prompt (Preserved & Optimized)
__prompt() {
  local ec=$? prefix="" git_info=""
  (( ec != 0 )) && prefix="\[\033[38;5;203m\][$ec]\[\033[0m\] "
  [[ -n "$VIRTUAL_ENV" ]] && prefix+="\[\033[38;5;183m\]($(basename "$VIRTUAL_ENV"))\[\033[0m\] "

  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    local dirty=$(git status --porcelain --untracked-files=no 2>/dev/null | head -1)
    local state="\[\033[38;5;114m\]✓\[\033[0m\]"
    [[ -n "$dirty" ]] && state="\[\033[38;5;203m\]✦\[\033[0m\]"
    git_info="\[\033[38;5;178m\]${branch}\[\033[0m\]${state} "
  fi

  PS1="${prefix}\[\033[38;5;141m\]\u\[\033[0m\]:\[\033[38;5;117m\]\w\[\033[0m\] ${git_info}\n\[\033[38;5;208m\]❯ \[\033[0m\]"
}
PROMPT_COMMAND=__prompt

# 256-Color LS_COLORS (Unchanged)
export LS_COLORS="di=38;5;51:ln=38;5;226:ex=38;5;118:*.sh=38;5;118:*.py=38;5;45:*.js=38;5;226:*.ts=38;5;226:*.json=38;5;214:*.md=38;5;231:*.txt=38;5;231:*.html=38;5;207:*.css=38;5;207:*.scss=38;5;207:*.env=38;5;196:*.lock=38;5;248:*.log=38;5;248:*.zip=38;5;201:*.tar=38;5;201:*.gz=38;5;201:*.png=38;5;135:*.jpg=38;5;135:*.jpeg=38;5;135:*.svg=38;5;135:*.gif=38;5;135:*.mp4=38;5;213:*.mp3=38;5;213:so=38;5;196:pi=38;5;196:"
