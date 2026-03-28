#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() {
    local GREEN="\033[0;32m"
    local NC="\033[0m"
    echo -e "[${GREEN}info${NC}] $1"
}

warn() {
    local YELLOW="\033[1;33m"
    local NC="\033[0m"
    echo -e "[${YELLOW}warning${NC}] $1"
}

error() {
    local RED="\033[0;31m"
    local NC="\033[0m"
    echo -e "[${RED}error${NC}] $1" >&2
}

require_macos() {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        error "This installer only supports macOS."
        exit 1
    fi
}

ensure_command() {
    local command_name="$1"
    local install_hint="$2"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        error "Missing required command: $command_name"
        error "$install_hint"
        exit 1
    fi
}

ensure_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        info "Homebrew already installed."
        return
    fi

    info "Installing Homebrew."
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    ensure_command "brew" "Homebrew installation failed."
}

ensure_brew_shellenv_loaded() {
    if command -v brew >/dev/null 2>&1; then
        return
    fi

    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    ensure_command "brew" "Install Homebrew first, then re-run this script."
}

brew_install_formula() {
    local formula="$1"

    if brew list --formula "$formula" >/dev/null 2>&1; then
        info "brew formula already installed: $formula"
        return
    fi

    info "Installing brew formula: $formula"
    brew install "$formula"
}

ensure_script_installed_command() {
    local command_name="$1"
    local install_command="$2"

    if command -v "$command_name" >/dev/null 2>&1; then
        info "command already installed: $command_name"
        return
    fi

    info "Installing $command_name."
    sh -c "$install_command"
}

path_points_into_repo() {
    local target_path="$1"

    if [[ ! -L "$target_path" ]]; then
        return 1
    fi

    local resolved_target
    resolved_target="$(perl -MCwd=realpath -e 'print realpath($ARGV[0])' "$target_path")"
    [[ "$resolved_target" == "$REPO_ROOT"/* ]]
}

brew_install_cask() {
    local cask="$1"

    if brew list --cask "$cask" >/dev/null 2>&1; then
        info "brew cask already installed: $cask"
        return
    fi

    info "Installing brew cask: $cask"
    brew install --cask "$cask"
}

ensure_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        info "Oh My Zsh already installed."
        return
    fi

    info "Installing Oh My Zsh."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

ensure_bob_nightly() {
    ensure_command "bob" "brew install bob"

    if [[ ! -d "$HOME/.local/bin" ]]; then
        mkdir -p "$HOME/.local/bin"
    fi

    info "Installing latest Neovim nightly with bob."
    bob install nightly
    bob use nightly

    local nvim_bin
    nvim_bin="$HOME/.local/share/bob/nvim-bin/nvim"
    if [[ ! -x "$nvim_bin" ]]; then
        error "bob did not produce an executable nvim binary at $nvim_bin"
        exit 1
    fi

    local version_output
    version_output="$("$nvim_bin" --version | head -n 1)"
    if [[ ! "$version_output" =~ ^NVIM[[:space:]]v([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
        error "Unable to parse Neovim version from: $version_output"
        exit 1
    fi

    local major="${BASH_REMATCH[1]}"
    local minor="${BASH_REMATCH[2]}"
    if (( major == 0 && minor < 12 )); then
        error "Installed Neovim version is too old: $version_output"
        error "Expected Neovim 0.12 or higher."
        exit 1
    fi

    info "Verified Neovim version: $version_output"
}

ensure_local_env_file() {
    local env_file="$HOME/.local/bin/env"

    mkdir -p "$(dirname "$env_file")"

    if [[ -f "$env_file" ]]; then
        info "Preserving existing $env_file"
        return
    fi

    info "Creating $env_file so zsh startup remains valid."
    cat >"$env_file" <<'EOF'
#!/bin/sh
# Local shell environment sourced by ~/.zshrc.
EOF
    chmod +x "$env_file"
}

backup_path() {
    local target="$1"
    local backup_target
    backup_target="${target}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$target" "$backup_target"
    warn "Backed up existing $target to $backup_target"
}

prepare_stow_target() {
    local target_path="$1"

    mkdir -p "$(dirname "$target_path")"

    if [[ -L "$target_path" ]] && path_points_into_repo "$target_path"; then
        info "Stow target already managed by this repo: $target_path"
        return
    fi

    if [[ -e "$target_path" || -L "$target_path" ]]; then
        backup_path "$target_path"
    fi
}

stow_packages() {
    prepare_stow_target "$HOME/.zshrc"
    prepare_stow_target "$HOME/.gitconfig"
    prepare_stow_target "$HOME/.config/nvim"
    prepare_stow_target "$HOME/.config/kitty"

    info "Applying dotfiles with stow."
    stow --target="$HOME" --restow zsh git nvim kitty
}

main() {
    require_macos

    ensure_command "curl" "Install curl via the Xcode Command Line Tools and re-run."
    ensure_command "zsh" "zsh is required on macOS."

    ensure_homebrew
    ensure_brew_shellenv_loaded

    info "Updating Homebrew metadata."
    brew update

    brew_install_formula "git"
    brew_install_formula "delta"
    brew_install_formula "fnm"
    brew_install_formula "bob"
    brew_install_formula "stow"
    brew_install_formula "tmux"
    brew_install_formula "fzf"
    brew_install_formula "tree"

    brew tap homebrew/cask-fonts
    brew_install_cask "kitty"
    brew_install_cask "font-jetbrains-mono-nerd-font"

    ensure_oh_my_zsh
    ensure_script_installed_command "uv" "curl -LsSf https://astral.sh/uv/install.sh | sh"
    ensure_script_installed_command "pnpm" "curl -fsSL https://get.pnpm.io/install.sh | sh -"
    ensure_bob_nightly
    ensure_local_env_file
    stow_packages

    info "macOS dotfiles bootstrap complete."
    info "Open a new terminal session to pick up shell changes."
}

main "$@"
