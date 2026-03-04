local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

---------------------------------------
-- Font (Nerd Font recommended)
---------------------------------------
config.font = wezterm.font('JetBrainsMono NF')
config.font_size = 12.0

---------------------------------------
-- Color Scheme
---------------------------------------
config.color_scheme = 'Tokyo Night'

---------------------------------------
-- Window
---------------------------------------
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.window_padding = {
  left = 8, right = 8, top = 8, bottom = 8,
}
config.initial_rows = 40
config.initial_cols = 140

---------------------------------------
-- Tab Bar
---------------------------------------
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false

---------------------------------------
-- Scrollback
---------------------------------------
config.scrollback_lines = 10000
config.enable_scroll_bar = true

-- Scrollbar & Tab Bar colors
config.colors = {
  scrollbar_thumb = '#888888',

  tab_bar = {
    background = '#1a1b26',

    active_tab = {
      bg_color = '#7aa2f7',
      fg_color = '#1a1b26',
      intensity = 'Bold',
    },

    inactive_tab = {
      bg_color = '#24283b',
      fg_color = '#565f89',
    },

    inactive_tab_hover = {
      bg_color = '#414868',
      fg_color = '#c0caf5',
      italic = true,
    },

    new_tab = {
      bg_color = '#1a1b26',
      fg_color = '#565f89',
    },

    new_tab_hover = {
      bg_color = '#414868',
      fg_color = '#c0caf5',
    },
  },
}

---------------------------------------
-- Shell Integration
---------------------------------------
config.term = 'xterm-256color'

---------------------------------------
-- Korean IME
---------------------------------------
config.use_ime = true
config.ime_preedit_rendering = 'Builtin'

---------------------------------------
-- Default Shell (PowerShell)
---------------------------------------
config.default_prog = { 'powershell.exe', '-NoLogo' }

---------------------------------------
-- Tab title: show current directory
---------------------------------------
wezterm.on('format-tab-title', function(tab)
  local pane = tab.active_pane
  local cwd = pane.current_working_dir
  if cwd then
    local path = cwd.file_path or tostring(cwd)
    path = path:gsub('^file:///',''):gsub('/$','')
    local folder = path:match('[/\\]([^/\\]+)$') or path
    return (tab.tab_index + 1) .. ': ' .. folder
  end
  return (tab.tab_index + 1) .. ': ' .. tab.active_pane.title
end)

---------------------------------------
-- Keybindings (Windows: CTRL based)
---------------------------------------
config.keys = {
  -- Pane split
  { key = 'd', mods = 'CTRL', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'e', mods = 'CTRL|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- Pane navigation
  { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'k', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'j', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },

  -- Pane resize
  { key = 'H', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'L', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },

  -- Close pane
  { key = 'w', mods = 'CTRL', action = act.CloseCurrentPane { confirm = true } },

  -- New tab
  { key = 't', mods = 'CTRL', action = act.SpawnTab 'CurrentPaneDomain' },

  -- Tab switching (Ctrl+1~9)
  { key = '1', mods = 'CTRL', action = act.ActivateTab(0) },
  { key = '2', mods = 'CTRL', action = act.ActivateTab(1) },
  { key = '3', mods = 'CTRL', action = act.ActivateTab(2) },
  { key = '4', mods = 'CTRL', action = act.ActivateTab(3) },
  { key = '5', mods = 'CTRL', action = act.ActivateTab(4) },
  { key = '6', mods = 'CTRL', action = act.ActivateTab(5) },
  { key = '7', mods = 'CTRL', action = act.ActivateTab(6) },
  { key = '8', mods = 'CTRL', action = act.ActivateTab(7) },
  { key = '9', mods = 'CTRL', action = act.ActivateTab(8) },

  -- Copy / Paste (Ctrl+C smart: copy when selected, interrupt otherwise)
  { key = 'c', mods = 'CTRL', action = wezterm.action_callback(function(window, pane)
    local sel = window:get_selection_text_for_pane(pane)
    if sel and sel ~= '' then
      window:perform_action(act.CopyTo 'Clipboard', pane)
    else
      window:perform_action(act.SendKey { key = 'c', mods = 'CTRL' }, pane)
    end
  end)},
  { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },

  -- Scroll navigation
  { key = 'End', mods = 'CTRL', action = act.ScrollToBottom },
  { key = 'Home', mods = 'CTRL', action = act.ScrollToTop },
  { key = 'u', mods = 'CTRL|ALT', action = act.ScrollByPage(-0.5) },
  { key = 'd', mods = 'CTRL|ALT', action = act.ScrollByPage(0.5) },
}

---------------------------------------
-- Mouse bindings (PuTTY-style right-click)
---------------------------------------
config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action_callback(function(window, pane)
      local sel = window:get_selection_text_for_pane(pane)
      if sel and sel ~= '' then
        window:perform_action(act.CopyTo 'ClipboardAndPrimarySelection', pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act.PasteFrom 'Clipboard', pane)
      end
    end),
  },
}

return config
