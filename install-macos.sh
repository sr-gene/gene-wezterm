#!/bin/bash
set -e

# Install JetBrainsMono Nerd Font (required by WezTerm config)
if fc-list | grep -qi "JetBrainsMono Nerd Font" 2>/dev/null || system_profiler SPFontsDataType 2>/dev/null | grep -qi "JetBrainsMono"; then
    echo "JetBrainsMono Nerd Font already installed."
else
    echo "Installing JetBrainsMono Nerd Font..."
    brew install --cask font-jetbrains-mono-nerd-font
fi

# Copy WezTerm config
cp wezterm-macos.lua ~/.wezterm.lua
echo "WezTerm config installed to ~/.wezterm.lua"

# Append zshrc additions if not already present
MARKER="# WezTerm OSC 7"
if grep -qF "$MARKER" ~/.zshrc 2>/dev/null; then
    echo "zshrc additions already present."
else
    echo "" >> ~/.zshrc
    cat zshrc-macos.sh >> ~/.zshrc
    echo "zshrc additions appended to ~/.zshrc"
fi
