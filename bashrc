# Core
[[ -f /etc/bashrc ]] && . /etc/bashrc
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export PATH

# Modular configs
if [[ -d ~/.bashrc.d ]]; then
  for rc in ~/.bashrc.d/*; do [[ -f "$rc" ]] && . "$rc"; done
  unset rc
fi

# Shell behavior
shopt -s checkwinsize autocd cdspell dirspell

# Completions
if ! shopt -oq posix; then
  [[ -f /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion
  [[ -f /etc/bash_completion ]] && . /etc/bash_completion
fi
command -v docker &>/dev/null && [[ ! -f /usr/share/bash-completion/completions/docker ]] && source <(docker completion bash 2>/dev/null)
command -v pip &>/dev/null && eval "$(pip completion --bash 2>/dev/null)"
command -v npm &>/dev/null && eval "$(npm completion 2>/dev/null)"

# ble.sh (install: curl -L https://github.com/akinomyoga/ble.sh/releases/latest/download/ble-nightly.tar.xz | tar xJf - -C ~/.local/share)
[[ $- == *i* ]] && [[ -f ~/.local/share/blesh/ble.sh ]] && source ~/.local/share/blesh/ble.sh --noattach

# Prompt (Purple User -> Light Blue Path -> Orange Arrow)
__build_prompt() {
  local ec=$? exit_info="" git_info="" venv_info=""
  # Semantic: Red for errors
  (( ec != 0 )) && exit_info="\[\033[38;5;203m\][$ec]\[\033[0m\] "

  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    local dirty=$(git status --porcelain 2>/dev/null | head -1)
    # Semantic: Green for clean, Red for dirty
    local state="\[\033[38;5;114m\]✓\[\033[0m\]"
    [[ -n "$dirty" ]] && state="\[\033[38;5;203m\]✦\[\033[0m\]"
    # Gradient: Gold (178) bridges Blue path to Orange prompt
    git_info=" \[\033[38;5;178m\]${branch}\[\033[0m\]${state}"
  fi

  # Gradient: Orchid (183) bridges Purple user to Blue path
  [[ -n "$VIRTUAL_ENV" ]] && venv_info=" \[\033[38;5;183m\]($(basename "$VIRTUAL_ENV"))\[\033[0m\]"

  # Target Colors: User(141 Purple) -> Path(117 Light Blue) -> Arrow(208 Orange)
  PS1="${exit_info}\[\033[38;5;141m\]\u\[\033[0m\]:\[\033[38;5;117m\]\w\[\033[0m\]${venv_info}${git_info}\n\[\033[38;5;208m\]❯ \[\033[0m\]"
}
PROMPT_COMMAND=__build_prompt

# Colors & Aliases (Harmonized with Purple-Blue-Orange)
export LS_COLORS="\
di=38;5;51:\
ln=38;5;226:\
ex=38;5;118:\
*.sh=38;5;118:\
*.py=38;5;45:\
*.js=38;5;226:\
*.ts=38;5;226:\
*.json=38;5;214:\
*.md=38;5;231:\
*.txt=38;5;231:\
*.html=38;5;207:\
*.css=38;5;207:\
*.scss=38;5;207:\
*.env=38;5;196:\
*.lock=38;5;248:\
*.log=38;5;248:\
*.zip=38;5;201:\
*.tar=38;5;201:\
*.gz=38;5;201:\
*.png=38;5;135:\
*.jpg=38;5;135:\
*.jpeg=38;5;135:\
*.svg=38;5;135:\
*.gif=38;5;135:\
*.mp4=38;5;213:\
*.mp3=38;5;213:\
so=38;5;196:\
pi=38;5;196:\
"
alias ls='ls --color=auto' ll='ls -lah --color=auto' la='ls -A --color=auto'

# ble.sh config
if [[ ${BLE_VERSION-} ]]; then
  bleopt complete_auto_delay=0 complete_auto_complete=1 complete_auto_history=0 history_share=1 complete_menu_style=desc complete_menu_maxlines=8 edit_abell=0
  
  # Matching UI Faces
  ble-face auto_complete='fg=244,italic'
  ble-face menu_desc_default='fg=249'
  ble-face menu_complete_selected='fg=117,bold'   # Light Blue (Matches path)
  ble-face menu_filter_fixed='fg=183'             # Orchid (Matches venv/input)
  ble-face syntax_command='fg=114'                # Semantic: Green
  ble-face syntax_error='fg=203,underline'        # Semantic: Red

  ble-bind -m auto_complete -f 'TAB' auto_complete/insert
  ble-bind -m auto_complete -f 'C-f' auto_complete/insert
  ble-bind -m auto_complete -f 'right' auto_complete/insert
  ble-attach
fi