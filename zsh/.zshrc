# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
#
export PATH="$HOME/.local/bin:$PATH"

if command -v brew >/dev/null 2>&1; then
  MYSQL_CLIENT_PREFIX="$(brew --prefix mysql-client 2>/dev/null || true)"
  if [[ -n "$MYSQL_CLIENT_PREFIX" ]]; then
    export PKG_CONFIG_PATH="${MYSQL_CLIENT_PREFIX}/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
  fi
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git git-prompt git-auto-fetch)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

if [[ -f "$HOME/.local/bin/env" ]]; then
  . "$HOME/.local/bin/env"
fi



alias vi="nvim"
alias x="exit"
alias zshrc="vi ~/.zshrc"

alias gs="git status"

nvimconfig() {
    local edit

    zparseopts -D -E e=edit --edit=edit

    cd ~/.config/nvim || return

    if (( ${#edit} )); then
        vi
    fi
}


vimm() {
  local file
  local -a fd_excludes=(
    --exclude __pycache__
    --exclude __marimo__
  )

  file="$(fd -I -t f . ${fd_excludes[@]} | fzf)" || return
  [[ -n "$file" ]] && vi "$file"
}

run_coplane () {
  if tmux has-session -t coplane 2>/dev/null; then
    echo "there's already a session called coplane"
    exit 1
  fi

  tmux new-session -d -s coplane -n frontend -c ~/dev/coplane/coplane/frontend

  tmux new-window -t coplane:1 -n backend -c ~/dev/coplane/coplane/backend

  tmux send-keys -t coplane:frontend 'pnpm run dev' Enter
  tmux send-keys -t coplane:backend 'uv run uvicorn main:app --reload --port 8080' Enter
}


goto () {
  local project_root="$HOME/dev"
  local project_dir
  local -a fd_excludes=(
    --exclude .git
    --exclude node_modules
    --exclude .venv
    --exclude __pycache__
  )

  project_dir="$(
    cd "$project_root" || return
    fd -I -t d . ${fd_excludes[@]} |
      rg -v '(^|/)\.venv(/|$)' |
      awk -F/ 'NF <= 4' |
      fzf
  )" || return

  echo "Going to $project_dir"

  cd "$project_root/$project_dir"
}


eval "$(fnm env --use-on-cd --shell zsh)"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
[[ -d "$PNPM_HOME" ]] && path=("$PNPM_HOME" $path)
# pnpm end

# bob / nvim
[[ -d "$HOME/.local/share/bob/nvim-bin" ]] && path=("$HOME/.local/share/bob/nvim-bin" $path)

# ensure no duplicates
typeset -U path PATH

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
