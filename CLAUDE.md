# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repo contains cross-platform WezTerm terminal emulator configuration files and shell setup. It is a dotfiles-style repo with no build system or tests — files are installed via platform-specific install scripts.

## Structure

- `wezterm-macos.lua` — macOS WezTerm config (CMD-based keybindings, font size 14.0 for Retina)
- `wezterm-windows.lua` — Windows WezTerm config (CTRL-based keybindings, font size 12.0, smart Ctrl+C, PowerShell default shell)
- `zshrc-macos.sh` — zsh shell additions for macOS (Oh My Posh, fzf, zoxide, aliases, OSC 7)
- `install-macos.sh` — macOS install script (copies config, appends zshrc)
- `install-windows.ps1` — Windows install script (copies config, adds OSC 7 to PowerShell profile)
- `install-windows.bat` — Wrapper to run install-windows.ps1 bypassing execution policy

## Installation

- **macOS**: `./install-macos.sh`
- **Windows**: double-click `install-windows.bat`

## Key Conventions

- Both WezTerm configs share identical theme (Tokyo Night), colors, scrollback, tab bar, and IME settings
- macOS uses `CMD` modifier; Windows uses `CTRL` for equivalent bindings
- Windows config includes a smart `Ctrl+C` callback (copies when text is selected, sends interrupt otherwise)
- Windows defaults to PowerShell (`config.default_prog`); macOS uses system default shell
- Both configs show current directory in tab title (`format-tab-title`) and right status bar (`update-status`, orange highlight)
- OSC 7 is required for directory tracking: macOS uses zshrc hook, Windows uses PowerShell profile hook
- Tab switching: macOS `Cmd+1-9` (built-in), Windows `Ctrl+1-9` (explicit keybindings)
- Comments in English
- Font requirement: JetBrainsMono Nerd Font

## Known Issues

- Windows: OSC 7 must be in PowerShell `$PROFILE` for directory tracking to work. Run `install-windows.bat` and restart PowerShell.
- Windows: after `cd` or pane switch, the right status bar path may not update if OSC 7 is not set up in the PowerShell profile.
