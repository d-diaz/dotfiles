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

# 5. Add missing Claude Code marketplaces ("name repo" per line)
while read -r name repo; do
    [ -z "$name" ] && continue
    if [ ! -d "$HOME/.claude/plugins/marketplaces/$name" ]; then
        echo "Adding Claude marketplace $name..."
        claude plugin marketplace add "$repo"
    fi
done <<'EOF'
claude-plugins-official anthropics/claude-plugins-official
ponytail DietrichGebert/ponytail
vibrantplanet Vibrant-Planet/vp-claude-marketplace
EOF

# 6. Install missing Claude Code plugins
INSTALLED_PLUGINS="$(claude plugin list 2>/dev/null)"
for plugin in \
    mattpocock-skills@claude-plugins-official \
    ponytail@ponytail \
    vp-engineering@vibrantplanet \
    vp-airflow-review@vibrantplanet; do
    if ! echo "$INSTALLED_PLUGINS" | grep -q "$plugin"; then
        echo "Installing Claude plugin $plugin..."
        claude plugin install -y "$plugin"
    fi
done