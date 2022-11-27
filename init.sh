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


# update apt package index
sudo apt update 
sudo apt upgrade -y


# update git
sudo add-apt-repository ppa:git-core/ppa -y
sudo apt update
sudo apt upgrade -y


# bunch of nice media codecs 
apt install ubuntu-restricted-extras


# https://stackoverflow.com/questions/53930305/nodemon-error-system-limit-for-number-of-file-watchers-reached
FILE_WATCH_COUNT=$(find /proc/*/fd -user "$USER" -lname anon_inode:inotify -printf '%hinfo/%f\n' 2>/dev/null | xargs cat | grep -c '^inotify')
if (( $FILE_WATCH_COUNT < 80000 ));
then
    info "increasing file watch count"
    echo fs.inotify.max_user_watches=80000 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
fi

if ! command -v xclip &> /dev/null
then
    info "installing xclip"
    sudo apt install xclip
else
    warn "skipping xclip install"
fi

if ! command -v neofetch &> /dev/null
then
    info "installing neofetch"
    sudo apt install neofetch
else
    warn "skipping neofetch install"
fi

# get my email
info "please enter your email, this will be associated to your git config"
read MY_EMAIL
git config --global user.name "Giorgio Delgado"
git config --global user.email "$MY_EMAIL"
git config --global core.editor "nvim"


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


if ! command -v brew &> /dev/null
then
    info "homebrew not installed, installing brew now"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # next steps to ensure `brew` is available in the PATH
    echo '# Set PATH, MANPATH, etc., for Homebrew.' >> /home/giorgiodelgado/.profile
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/giorgiodelgado/.profile
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    # Install Homebrew's dependencies if you have sudo access:
    sudo apt install build-essential
else
    warn "homebrew already installed, skipping install"
fi

if ! command -v node &> /dev/null
then
    info "installing nvm (Node Version Manager)"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    # source .zshrc so that `nvm` is recognized in the current session
    source .zshrc
    nvm install --lts
fi

if ! command -v prettierd &> /dev/null
then
    info "installing prettier daemon"
    npm install -g @fsouza/prettierd
fi

if ! command -v nvim &> /dev/null
then
    info "neovim not installed, installing neovim now"
    brew install neovim

    info "symlinking nvim config to ~/.config/nvim"
    ln -s ~/dotfiles/nvim ~/.config/nvim

    info "installing packer to manage neovim plugins / deps"
    git clone --depth 1 \
        https://github.com/wbthomason/packer.nvim \
        ~/.local/share/nvim/site/pack/packer/start/packer.nvim

    info "preparing to add custom NERDFont"
    # mkdir -p ~/.local/share/fonts
    git clone --filter=blob:none --sparse git@github.com:ryanoasis/nerd-fonts
    cd nerd-fonts
    git sparse-checkout add patched-fonts/JetBrainsMono
    ./install.sh JetBrainsMono
    info "installed JetBrainsMono"
    cd ..
else
    warn "neovim already installed, skipping install"
fi


if ! command -v jq &> /dev/null
then
    info "installing jq"
    brew install jq
else 
    warn "jq already installed, skipping jq install"
fi

if ! command -v rg &> /dev/null
then 
    info "installing ripgrep"
    brew install ripgrep
else
    warn "rg binnary found - skipping ripgrep installation"
fi

if ! command -v gh &> /dev/null
then 
    info "installing github cli"
    brew install gh
else
    warn "gh binnary found - skipping github cli"
fi

if ! command -v fzf &> /dev/null
then
    info "installing fzf "
    brew install fzf
else 
    warn "fzf already installed, skipping jq install"
fi

if ! command -v fdfind &> /dev/null
then
    info "installing fd (find alternative)"
    sudo apt install fd-find
    mkdir ~/.local/bin
    ln -s $(which fdfind) ~/.local/bin/fd
else
    warn "command 'fd' found, skipping fd installation"
fi

if ! command -v deno &> /dev/null
then
    info "installing deno"
    curl -fsSL https://deno.land/install.sh | sh
else
    warn "command 'deno' found, skipping deno installation"
fi


if ! command -v diff-so-fancy &> /dev/null
then
    info "installing diff-so-fancy"
    brew install diff-so-fancy 

    info "updating git settings to use diff-so-fancy"
    git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
    git config --global interactive.diffFilter "diff-so-fancy --patch"

    git config --global color.ui true

    git config --global color.diff-highlight.oldNormal    "red bold"
    git config --global color.diff-highlight.oldHighlight "red bold 52"
    git config --global color.diff-highlight.newNormal    "green bold"
    git config --global color.diff-highlight.newHighlight "green bold 22"

    git config --global color.diff.meta       "11"
    git config --global color.diff.frag       "magenta bold"
    git config --global color.diff.func       "146 bold"
    git config --global color.diff.commit     "yellow bold"
    git config --global color.diff.old        "red bold"
    git config --global color.diff.new        "green bold"
    git config --global color.diff.whitespace "red reverse"
else 
    warn "diff-so-fancy already installed, skipping diff-so-fancy install"
fi

if ! command -v kitty &> /dev/null
then
    info "kitty not installed, installing kitty now"
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    info "symlinking custom kitty.conf"
    ln -s ~/dotfiles/kitty.conf ~/.config/kitty/kitty.conf

    # PopOS-specific: Ensure that Kitty can be accessed via the launcher
    # https://www.arm64.ca/post/creating-launch-plugins-for-pop-os-updated/
    mkdir -p $HOME/.local/share/pop-launcher/scripts
    printf '%s\n' \
        '#!/bin/sh' \
        '#' \
        '# name: Kitty' \
        "# icon: $HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png" \
        '# description: Launch Kitty' \
        '# keywords: kitty terminal' \
        '' \
        "$HOME/.local/kitty.app/bin/kitty" > $HOME/.local/share/pop-launcher/scripts/kitty.sh

    chmod +x $HOME/.local/share/pop-launcher/scripts/kitty.sh
else
    warn "kitty already installed, skipping install"
fi


# if ! command -v mysqlsh &> /dev/null
# then
#    info "mysqlsh not installed, installing mysqlsh now"
#
# else
# fi

if ! command -v docker &> /dev/null
then
    # https://docs.docker.com/engine/install/ubuntu
    info "installing docker"
    sudo apt install \
        ca-certificates \
        lsb-release

    info "adding docker's GPG key"
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    info "setting up docker repository"
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    info "installing docker engine"
    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.11.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose


    # ensure that various docker commands have permission to run
    # https://linuxhandbook.com/docker-permission-denied/
    sudo groupadd docker &> /dev/null || echo "created docker group"
    sudo usermod -aG docker $USER
else
    info "docker already installed, skipping docker installation"
fi

if ! command -v gcloud &> /dev/null
then
    info "beginning install of 'gcloud' cli"

    # Gcloud CLI Stuff
    # https://cloud.google.com/sdk/docs/install#deb
    sudo apt install apt-transport-https ca-certificates gnupg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt update && sudo apt install google-cloud-cli
    gcloud init
else
    warn "'gcloud' already installed, skipping gcloud cli install"
fi

if ! command -v ~/cloud_sql_proxy &> /dev/null
then
    info "beginning install of cloud sql proxy"

    wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O ~/cloud_sql_proxy
    chmod +x ~/cloud_sql_proxy
else
    warn "cloud sql proxy already installed at $HOME - skipping cloud sql proxy install"
fi
