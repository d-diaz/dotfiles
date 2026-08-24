#!/bin/bash

# 1. Install Oh My Zsh (unattended)
if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    echo "Installing Oh My Zsh..."
    rm -rf "$HOME/.oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 2. Symlink dotfiles from repo to home
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/.gitconfig-vp ~/.gitconfig-vp

# 3. Clone missing plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# 4. Install Claude Code (native build, no node required)
export PATH="$HOME/.local/bin:$PATH"
if ! command -v claude >/dev/null 2>&1; then
    echo "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
fi

# 5. Make host-written plugin paths resolve in containers.
# installed_plugins.json stores absolute paths like /home/ddiaz/.claude/...
# which don't exist under a container user's home. No-op on the host.
if [ ! -e /home/ddiaz ]; then
    echo "Linking /home/ddiaz -> $HOME for Claude plugin paths..."
    sudo ln -s "$HOME" /home/ddiaz
fi
