Version 0.1.0.0 — 2026-04-30

# WezTerm Setup

Cross-platform WezTerm terminal configuration with Tokyo Night theme.

## Files

| File | Description |
|------|-------------|
| `wezterm-macos.lua` | macOS config (`CMD` based keybindings) |
| `wezterm-windows.lua` | Windows config (`CTRL` based keybindings) |

## Installation

### macOS
```bash
cp wezterm-macos.lua ~/.wezterm.lua
```

### Windows
```powershell
Copy-Item wezterm-windows.lua $HOME\.wezterm.lua
```

> Requires [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads) installed.

## Features

- **Theme**: Tokyo Night with custom tab bar colors
- **Font**: JetBrainsMono Nerd Font
- **Scrollback**: 10,000 lines with visible scrollbar
- **Korean IME**: Enabled with builtin preedit rendering
- **Tab bar**: Minimal style at top, always visible
- **Default shell (Windows)**: PowerShell (instead of cmd.exe)

## Keybindings

| Action | macOS | Windows |
|--------|-------|---------|
| Split horizontal | `Cmd+D` | `Ctrl+D` |
| Split vertical | `Cmd+Shift+E` | `Ctrl+Shift+E` |
| Close pane | `Cmd+W` | `Ctrl+W` |
| New tab | `Cmd+T` | `Ctrl+T` |
| Switch to tab 1–9 | `Cmd+1–9` | `Ctrl+1–9` |
| Copy | `Cmd+C` | `Ctrl+C` (smart*) |
| Paste | `Cmd+V` | `Ctrl+V` |
| Move pane left/down/up/right | `Alt+H/J/K/L` | `Alt+H/J/K/L` |
| Resize pane left/right | `Alt+Shift+H/L` | `Alt+Shift+H/L` |
| Scroll to top | `Cmd+Home` | `Ctrl+Home` |
| Scroll to bottom | `Cmd+End` | `Ctrl+End` |
| Scroll half page up | `Cmd+Alt+U` | `Ctrl+Alt+U` |
| Scroll half page down | `Cmd+Alt+D` | `Ctrl+Alt+D` |
| Right-click (smart†) | Copy or Paste | Copy or Paste |

\* **Smart Ctrl+C (Windows)**: Copies text when a selection exists, sends interrupt signal (SIGINT) when nothing is selected.

† **PuTTY-style right-click (both platforms)**: Right-click copies text when a selection exists, pastes from clipboard when nothing is selected.


## Key Differences Between macOS and Windows Configs

- **Modifier keys**: macOS uses `CMD`, Windows uses `CTRL`
- **Font size**: macOS `14.0` (Retina), Windows `12.0`
- **Smart copy**: Windows has smart `Ctrl+C` to avoid conflict with terminal interrupt
- **Default shell**: Windows defaults to PowerShell; macOS uses system default
- **Fullscreen**: macOS config enables `native_macos_fullscreen_mode`
