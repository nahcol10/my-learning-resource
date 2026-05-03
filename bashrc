# ~/.bashrc - Minimal ML (.venv focused)

[[ -f /etc/bashrc ]] && . /etc/bashrc
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && PATH="$HOME/.local/bin:$HOME/bin:$PATH"

shopt -s checkwinsize autocd histappend
HISTSIZE=30000; HISTFILESIZE=60000

if ! shopt -oq posix && [[ -f /usr/share/bash-completion/bash_completion ]]; then
  . /usr/share/bash-completion/bash_completion
fi

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

# Fixed: correct semicolons for 256-color codes, colons only as separators
export LS_COLORS="di=38;5;51:ln=38;5;226:ex=38;5;118:*.sh=38;5;118:*.py=38;5;45:*.js=38;5;226:*.ts=38;5;226:*.json=38;5;214:*.md=38;5;231:*.txt=38;5;231:*.html=38;5;207:*.css=38;5;207:*.scss=38;5;207:*.env=38;5;196:*.lock=38;5;248:*.log=38;5;248:*.zip=38;5;201:*.tar=38;5;201:*.gz=38;5;201:*.png=38;5;135:*.jpg=38;5;135:*.jpeg=38;5;135:*.svg=38;5;135:*.gif=38;5;135:*.mp4=38;5;213:*.mp3=38;5;213:so=38;5;196:pi=38;5;196:"
alias ls='ls --color=auto' ll='ls -lah --color=auto' la='ls -A --color=auto'

if [[ $- == *i* && -f ~/.local/share/blesh/ble.sh ]]; then
  source ~/.local/share/blesh/ble.sh --noattach 2>/dev/null && {
    bleopt complete_auto_delay=0 complete_auto_complete=1 history_share=1
    ble-face menu_complete_selected='fg=117,bold' menu_filter_fixed='fg=183'
    ble-face syntax_command='fg=114' syntax_error='fg=203'
    ble-attach
  }
fi
