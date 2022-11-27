export DENO_INSTALL="/home/giorgiodelgado/.deno"
export KITTY_PATH="/home/giorgiodelgado/.local/kitty.app"
export PATH=/usr/bin:$HOME/bin:/usr/local/bin:$HOME/.local/bin:$DENO_INSTALL/bin:$KITTY_PATH/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# https://old.reddit.com/r/neovim/comments/wcvkez/strange_characters_appear_when_using_neovim_as/
export MANPAGER='nvim +Man!'


# By using fd (instead of `find`), I can performantly ignore files
# inside of directories containing a `.gitignore`
#    e.g. node_modules, build / dist directories, etc
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix'


# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
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
plugins=(git colorize)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias vi=nvim
alias neovim=nvim
alias c=/usr/bin/clear
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'
alias gs="git status"
alias sdiff="git diff | git-split-diffs --color | less -RFX"
alias gch="git branch | fzf | xargs git checkout"

function notes() {
  kitty @ launch --title "notes" --type os-window --cwd ~/Desktop/notes nvim -c "NvimTreeToggle"
}

function masterPass() {
  pbcopy < ~/Desktop/notes/pass.txt
}

function vimm() {
  vi $(fzf)
}

function fnpm() {
  npm run $(jq -r '.scripts | keys[]' package.json | fzf --height=10)
}

function x() {
  exit
}

function goto () {
  # local ABSOLUTE_PATH="/Users/giorgiodelgado/code" 
  local PROJECT_DIR=$(find ~/code \( -name .git -o -name node_modules -o -name elm-stuff -o -name .stack-work \) -prune -o -type d -print | awk '{ gsub("/Users/giorgiodelgado/code/", ""); print $0 }' | fzf) 
  # cd "$ABSOLUTE_PATH/$PROJECT_DIR"
  cd $PROJECT_DIR
}

# https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-an-array-in-bash
function join_by { local d=$1; shift; local f=$1; shift; printf %s "$f" "${@/#/$d}"; }

function dbproxy () {
	local ENVIRONMENTS=("staging" "production") 
	local FZF_STRING=$(join_by "\n" "${ENVIRONMENTS[@]}") 
	local SELECTED_ENV=$(echo $FZF_STRING | fzf) 
	if [ "$SELECTED_ENV" = "staging" ]
	then
		echo "> Running staging proxy"
		~/cloud_sql_proxy -instances=caribou-staging-303716:us-east1:caribou-staging=tcp:3309
	elif [ "$SELECTED_ENV" = "production" ]
	then
		echo "> Running prod proxy"
		~/cloud_sql_proxy -instances=caribou-production:us-east1:caribou-production=tcp:3306
	else
		echo "> unrecognized env selected"
		exit 1
	fi
}

function nvimconfig () {
    cd ~/.config/nvim
    vi init.lua
}


# hooks
# autoload: man zshbuiltins
# add-zsh-hook: man zshcontrib
# https://www.halcyon.hr/posts/automatic-dark-mode-switching-for-vim-and-terminal/

autoload -U add-zsh-hook
change-color-pwd() {
  # check file exists, is regular file and is readable:
  if [[ $PWD -ef "/home/pyrho/repos/caribou/api-server" ]]; then
    # could also source the kitty theme if its inside a given dir
    kitty @ set-colors foreground=red background=white
  fi

  if [[ $PWD -ef "/home/pyrho/repos/caribou/frontends" ]]; then
    # could also source the kitty theme if its inside a given dir
    kitty @ set-colors foreground=blue background=black
  fi
}

add-zsh-hook chpwd change-color-pwd


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/giorgiodelgado/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/giorgiodelgado/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/giorgiodelgado/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/giorgiodelgado/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/giorgiodelgado/google-cloud-sdk/path.zsh.inc' ]; then . '/home/giorgiodelgado/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/giorgiodelgado/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/giorgiodelgado/google-cloud-sdk/completion.zsh.inc'; fi
