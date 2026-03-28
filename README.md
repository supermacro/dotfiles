# Dotfiles

This repo contains my macOS dotfiles and uses GNU Stow to manage symlinks.

## Layout

Each top-level directory is a Stow package rooted at `$HOME`.

- `zsh/.zshrc` -> `~/.zshrc`
- `git/.gitconfig` -> `~/.gitconfig`
- `nvim/.config/nvim/...` -> `~/.config/nvim/...`
- `kitty/.config/kitty/...` -> `~/.config/kitty/...`

## Bootstrap

Run:

```sh
./init.sh
```

On macOS this script will:

- install Homebrew if needed
- install the declared dependencies: `git`, `delta`, `fnm`, `bob`, `stow`, `tmux`, `fzf`, `uv`, `pnpm`, `kitty`, and JetBrainsMono Nerd Font
- install Oh My Zsh if needed
- install Neovim nightly with `bob` and verify the version is `0.12+`
- create `~/.local/bin/env` if it does not exist
- back up conflicting files and apply the repo with `stow`

## Manual Stow Usage

From the repo root:

```sh
stow --target="$HOME" --restow zsh git nvim kitty
```

If one of the target files already exists and is not managed by this repo, move it out of the way first or let `init.sh` back it up for you.
