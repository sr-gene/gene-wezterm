#!/bin/bash
set -e

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
