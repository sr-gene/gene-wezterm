local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

-- Extract valid Windows path from WezTerm's cwd URL
local function get_cwd(pane)
  local cwd = pane:get_current_working_dir()
  if not cwd then return nil end
  local path = cwd.file_path or tostring(cwd)
  -- Extract Windows drive-letter path from any prefix (e.g. /HOSTNAME/C:/... or /C:/...)
  return path:match('([A-Za-z]:[/\\].*)') or path
end

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
-- Session restore
---------------------------------------
local session_file = wezterm.home_dir .. '/.wezterm_session.json'
local last_save_time = 0

local function save_session(window)
  local now = os.time()
  if now - last_save_time < 30 then return end
  last_save_time = now
  local tabs = {}
  for _, tab in ipairs(window:mux_window():tabs()) do
    local path = get_cwd(tab:active_pane())
    if path then table.insert(tabs, path) end
  end
  local f = io.open(session_file, 'w')
  if f then f:write(wezterm.json_encode(tabs)); f:close() end
end

wezterm.on('gui-startup', function(cmd)
  local f = io.open(session_file, 'r')
  if not f then wezterm.mux.spawn_window(cmd or {}); return end
  local data = f:read('*a'); f:close()
  local tabs = wezterm.json_decode(data)
  if not tabs or #tabs == 0 then wezterm.mux.spawn_window(cmd or {}); return end
  local _, _, window = wezterm.mux.spawn_window({ cwd = tabs[1] })
  for i = 2, #tabs do window:spawn_tab({ cwd = tabs[i] }) end
end)

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

-- Status bar: show full working directory path on the right side of tab bar
wezterm.on('update-status', function(window, pane)
  save_session(window)
  local cwd = pane:get_current_working_dir()
  local path = ''
  if cwd then
    path = cwd.file_path or tostring(cwd)
    path = path:gsub('^file:///',''):gsub('/$','')
  end
  window:set_right_status(wezterm.format {
    { Foreground = { Color = '#ff9e64' } },
    { Text = '  ' .. path .. '  ' },
  })
end)

---------------------------------------
-- Keybindings (Windows: CTRL based)
---------------------------------------
config.keys = {
  -- Pane split (inherit current directory)
  { key = 'd', mods = 'CTRL', action = wezterm.action_callback(function(window, pane)
    window:perform_action(act.SplitHorizontal { domain = 'CurrentPaneDomain', cwd = get_cwd(pane) }, pane)
  end)},
  { key = 'e', mods = 'CTRL|SHIFT', action = wezterm.action_callback(function(window, pane)
    window:perform_action(act.SplitVertical { domain = 'CurrentPaneDomain', cwd = get_cwd(pane) }, pane)
  end)},

  -- Pane navigation
  { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'k', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'j', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },

  -- Pane resize
  { key = 'H', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'L', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },

  -- New window (inherit current directory)
  { key = 'n', mods = 'CTRL', action = wezterm.action_callback(function(window, pane)
    window:perform_action(act.SpawnCommandInNewWindow { cwd = get_cwd(pane), domain = 'CurrentPaneDomain' }, pane)
  end)},

  -- Close pane
  { key = 'w', mods = 'CTRL', action = act.CloseCurrentPane { confirm = true } },

  -- New tab (inherit current directory)
  { key = 't', mods = 'CTRL', action = wezterm.action_callback(function(window, pane)
    window:perform_action(act.SpawnCommandInNewTab { cwd = get_cwd(pane), domain = 'CurrentPaneDomain' }, pane)
  end)},

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
