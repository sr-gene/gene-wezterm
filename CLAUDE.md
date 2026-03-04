# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repo contains cross-platform WezTerm terminal emulator configuration files and shell setup. It is a dotfiles-style repo with no build system or tests — files are manually copied to their target locations.

## Structure

- `wezterm-macos.lua` — macOS WezTerm config (CMD-based keybindings, font size 14.0 for Retina)
- `wezterm-windows.lua` — Windows WezTerm config (CTRL+SHIFT-based keybindings, font size 12.0, smart Ctrl+C)
- `zshrc-macos.sh` — zsh shell additions for macOS (Oh My Posh, fzf, zoxide, aliases, OSC 7)

## Installation

Config files are copied to the user's home directory:
- WezTerm: `cp wezterm-<platform>.lua ~/.wezterm.lua`
- Zsh: append `zshrc-macos.sh` contents to `~/.zshrc`

## Key Conventions

- Both WezTerm configs share identical theme (Tokyo Night), colors, scrollback, tab bar, and IME settings
- macOS uses `CMD` modifier; Windows uses `CTRL+SHIFT` for equivalent bindings
- Windows config includes a smart `Ctrl+C` callback (copies when text is selected, sends interrupt otherwise)
- Comments in the Lua configs are in Korean
- Font requirement: JetBrainsMono Nerd Font
