#!/bin/bash
set -e

# Update WezTerm config
cp wezterm-macos.lua ~/.wezterm.lua
echo "WezTerm config updated at ~/.wezterm.lua"

# Update JetBrainsMono Nerd Font
echo "Updating JetBrainsMono Nerd Font..."
brew upgrade --cask font-jetbrains-mono-nerd-font 2>/dev/null || echo "Font already up to date."

# Update zshrc additions
MARKER="# WezTerm OSC 7"
if grep -qF "$MARKER" ~/.zshrc 2>/dev/null; then
    echo "zshrc additions already present (not re-appended)."
else
    echo "" >> ~/.zshrc
    cat zshrc-macos.sh >> ~/.zshrc
    echo "zshrc additions appended to ~/.zshrc"
fi

echo "Update complete. Restart WezTerm to apply changes."
