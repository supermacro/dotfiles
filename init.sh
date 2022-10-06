#!/bin/bash

#### 
# config 
# https://stackoverflow.com/a/5947802
info () {
    local GREEN="\033[0;32m"
    local NC="\033[0m"
    echo -e "[${GREEN}info${NC}] $1"
}

warn () {
    local YELLOW="\033[1;33m"
    local NC="\033[0m"
    echo -e "[${YELLOW}warning${NC}] $1"
}


# update git

sudo apt update && sudo apt upgrade -y

# update git
sudo add-apt-repository ppa:git-core/ppa -y
sudo apt update
sudo apt upgrade -y

# get my email
info "please enter your email, this will be associated to your git config"
read MY_EMAIL
git config --global user.name "Giorgio Delgado"
git config --global user.email "$MY_EMAIL"


# Before restoring:
#   - get code in staging

# want to install:
#   - neovim
#       - pull my lua files from github
#   - kitty
#   - zshell
#   - gcloud cli
#   - google cloud proxy

# 0 - install zsh + ohmyzsh
# ensure that zsh is the default shell

if [[ "$SHELL" == *zsh ]] 
then
    # user has zsh already as their default shell
    info "User already has zsh set up as their main shell"
else
    # first check to see if zsh is even available on their machine
    if ! command -v zsh &> /dev/null
    then
        # user needs to install zsh 
        info "installing zsh"
        sudo apt install zsh
        info "completed installing zsh"
    fi    
fi


OH_MY_ZSH_DIR=~/.oh-my-zsh
if [[ ! -d "$OH_MY_ZSH_DIR" ]]
then
    info "Installing ohmyzsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    warn "found .oh-my-zsh folder - skipping ohmyzsh install"
fi

info "symlinking custom .zshrc to ~"
# remove default .zshrc 
rm ../.zshrc 
# create symlink
ln -s ~/dotfiles/.zshrc ~/.zshrc


# 1 - install homebrew

if ! command -v brew &> /dev/null
then
    info "homebrew not installed, installing brew now"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # next steps to ensure `brew` is available in the PATH
    echo '# Set PATH, MANPATH, etc., for Homebrew.' >> /home/giorgiodelgado/.profile
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/giorgiodelgado/.profile
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    # Install Homebrew's dependencies if you have sudo access:
    sudo apt-get install build-essential
else
    warn "homebrew already installed, skipping install"
fi


# 2 - install neovim
if ! command -v nvim &> /dev/null
then
    info "neovim not installed, installing neovim now"
    brew install neovim
    # TODO: need to move into PATH
else
    warn "neovim already installed, skipping install"
fi


# 3 - install kitty 
if ! command -v kitty &> /dev/null
then
    info "kitty not installed, installing kitty now"
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
else
    warn "kitty already installed, skipping install"
fi
