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
-- Default Shell (PowerShell 7)
---------------------------------------
config.default_prog = { 'pwsh.exe', '-NoLogo' }

---------------------------------------
-- Window
---------------------------------------
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.window_close_confirmation = 'AlwaysPrompt'
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
  compose_cursor = '#ff9e64',

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

-- Performance: reduce input latency
config.animation_fps = 1
config.cursor_blink_rate = 0
config.front_end = 'WebGpu'

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
-- Smart Paste (files/images/text detection)
-- Files from Explorer -> quoted paths
-- Images (screenshots) -> temp PNG path
-- Text -> default WezTerm paste (Claude Code compatible)
---------------------------------------
local smart_paste_action = wezterm.action_callback(function(window, pane)
  local function fallback_paste()
    window:perform_action(act.PasteFrom 'Clipboard', pane)
  end

  local home = os.getenv('USERPROFILE') or os.getenv('HOME') or ''
  local script_path = home .. '\\.wezterm_clipboard.ps1'

  local success, stdout = wezterm.run_child_process({
    'powershell.exe', '-NoProfile', '-STA', '-ExecutionPolicy', 'Bypass',
    '-File', script_path,
  })

  if not success or not stdout or stdout == '' then
    fallback_paste()
    return
  end

  local first_line, rest = stdout:match("^([^\r\n]+)[\r\n]+(.*)")
  if not first_line then
    first_line = stdout:gsub('%s+$', '')
    rest = ''
  end

  if first_line == '__FILES__' or first_line == '__IMAGE__' then
    local path = rest:gsub('^%s+', ''):gsub('%s+$', '')
    if path and path ~= '' then
      pane:send_text(path)
    else
      fallback_paste()
    end
  else
    fallback_paste()
  end
end)

---------------------------------------
-- F1 Cheatsheet data
---------------------------------------
local cheatsheet_choices = {
  { label = '-- Tab ----------------------------------' },
  { label = 'Ctrl+T              New tab' },
  { label = 'Ctrl+Tab            Next tab' },
  { label = 'Ctrl+Shift+Tab      Previous tab' },
  { label = 'Ctrl+W              Close tab/pane' },
  { label = 'Ctrl+1-9            Switch to tab' },
  { label = '' },
  { label = '-- Pane ---------------------------------' },
  { label = 'Ctrl+D              Split horizontal' },
  { label = 'Ctrl+Shift+E        Split vertical' },
  { label = 'Alt+H/J/K/L         Navigate panes' },
  { label = 'Alt+Shift+H/L       Resize panes' },
  { label = 'Ctrl+Shift+Z        Zoom pane' },
  { label = 'Ctrl+Shift+S        Select pane' },
  { label = 'Ctrl+Shift+X        Swap pane' },
  { label = 'Ctrl+Shift+B        Break pane to tab' },
  { label = '' },
  { label = '-- Scroll -------------------------------' },
  { label = 'Ctrl+Home/End       Scroll top/bottom' },
  { label = 'Ctrl+Alt+U/D        Half-page scroll' },
  { label = '' },
  { label = '-- Copy / Paste -------------------------' },
  { label = 'Ctrl+C              Smart copy/interrupt' },
  { label = 'Ctrl+V              Paste' },
  { label = 'Ctrl+Shift+V        Smart paste (files/images)' },
  { label = 'Right-click         Copy or paste' },
  { label = '' },
  { label = '-- Utility ------------------------------' },
  { label = 'F1                  This cheatsheet' },
  { label = 'Ctrl+Shift+P        Smart Palette' },
  { label = 'Ctrl+Shift+I        Theme selector' },
  { label = 'Ctrl+Shift+O        Font selector' },
  { label = 'Ctrl+Shift+L        Launch menu' },
  { label = 'Ctrl+N              New window' },
}

---------------------------------------
-- Smart Palette data
---------------------------------------
local palette_commands = {
  { id = 'new_tab',      label = 'New tab' },
  { id = 'close',        label = 'Close tab/pane' },
  { id = 'next_tab',     label = 'Next tab' },
  { id = 'prev_tab',     label = 'Previous tab' },
  { id = 'rename_tab',   label = 'Rename tab' },
  { id = 'split_h',      label = 'Split horizontal' },
  { id = 'split_v',      label = 'Split vertical' },
  { id = 'zoom',         label = 'Zoom pane' },
  { id = 'select_pane',  label = 'Select pane' },
  { id = 'swap_pane',    label = 'Swap pane' },
  { id = 'break_pane',   label = 'Break pane to new tab' },
  { id = 'copy',         label = 'Copy' },
  { id = 'paste',        label = 'Paste' },
  { id = 'search',       label = 'Search text' },
  { id = 'copy_mode',    label = 'Copy Mode (Vim-style select)' },
  { id = 'font_up',      label = 'Increase font size' },
  { id = 'font_down',    label = 'Decrease font size' },
  { id = 'font_reset',   label = 'Reset font size' },
  { id = 'fullscreen',   label = 'Toggle fullscreen' },
  { id = 'theme',        label = 'Change theme' },
  { id = 'font_select',  label = 'Change font' },
  { id = 'launch_menu',  label = 'Launch menu' },
  { id = 'new_window',   label = 'New window' },
  { id = 'reload',       label = 'Reload configuration' },
  { id = 'cheatsheet',   label = 'Keyboard shortcuts (F1)' },
}

local palette_actions = {
  new_tab     = act.SpawnTab 'CurrentPaneDomain',
  close       = act.CloseCurrentPane { confirm = true },
  next_tab    = act.ActivateTabRelative(1),
  prev_tab    = act.ActivateTabRelative(-1),
  rename_tab  = act.PromptInputLine {
    description = wezterm.format {
      { Foreground = { AnsiColor = 'Aqua' } },
      { Text = 'Enter tab name:' },
    },
    action = wezterm.action_callback(function(window, pane, line)
      if line then window:active_tab():set_title(line) end
    end),
  },
  split_h     = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
  split_v     = act.SplitVertical { domain = 'CurrentPaneDomain' },
  zoom        = act.TogglePaneZoomState,
  select_pane = act.PaneSelect {},
  swap_pane   = act.PaneSelect { mode = 'SwapWithActive' },
  copy        = act.CopyTo 'Clipboard',
  paste       = act.PasteFrom 'Clipboard',
  search      = act.Search { CaseInSensitiveString = '' },
  copy_mode   = act.ActivateCopyMode,
  font_up     = act.IncreaseFontSize,
  font_down   = act.DecreaseFontSize,
  font_reset  = act.ResetFontSize,
  fullscreen  = act.ToggleFullScreen,
  launch_menu = act.ShowLauncherArgs { flags = 'LAUNCH_MENU_ITEMS' },
  new_window  = act.SpawnWindow,
  reload      = act.ReloadConfiguration,
}

---------------------------------------
-- Theme Selector data
---------------------------------------
local theme_choices = {
  { id = 'Tokyo Night',                     label = 'Tokyo Night (default)' },
  { id = 'Catppuccin Mocha',                label = 'Catppuccin Mocha' },
  { id = 'One Dark (Gogh)',                 label = 'One Dark' },
  { id = 'Dracula',                         label = 'Dracula' },
  { id = 'Gruvbox dark, medium (base16)',   label = 'Gruvbox Dark' },
  { id = 'Nord',                            label = 'Nord' },
  { id = 'Solarized Dark (Gogh)',           label = 'Solarized Dark' },
  { id = 'Kanagawa (Gogh)',                 label = 'Kanagawa' },
  { id = 'rose-pine',                       label = 'Rose Pine' },
  { id = 'Everforest Dark (Gogh)',          label = 'Everforest Dark' },
  { id = 'GitHub Dark',                     label = 'GitHub Dark' },
}

---------------------------------------
-- Font Selector data
---------------------------------------
local font_choices = {
  { id = 'JetBrainsMono NF',   label = 'JetBrainsMono (default)' },
  { id = 'CaskaydiaCove NF',   label = 'Cascadia Code' },
  { id = 'FiraCode NF',        label = 'Fira Code' },
  { id = 'Hack NF',            label = 'Hack' },
  { id = 'MesloLGS NF',        label = 'MesloLGS' },
  { id = 'SourceCodePro NF',   label = 'Source Code Pro' },
  { id = 'UbuntuMono NF',      label = 'Ubuntu Mono' },
  { id = 'RobotoMono NF',      label = 'Roboto Mono' },
}

---------------------------------------
-- Reusable selector actions
---------------------------------------
local cheatsheet_action = act.InputSelector {
  title = 'Keyboard Shortcuts (type to search)',
  fuzzy = true,
  fuzzy_description = 'Search shortcuts...',
  choices = cheatsheet_choices,
  action = wezterm.action_callback(function() end),
}

local theme_selector_action = act.InputSelector {
  title = 'Select Theme (applied immediately)',
  fuzzy = true,
  fuzzy_description = 'Search themes...',
  choices = theme_choices,
  action = wezterm.action_callback(function(window, pane, id)
    if id then
      local overrides = window:get_config_overrides() or {}
      overrides.color_scheme = id
      window:set_config_overrides(overrides)
    end
  end),
}

local font_selector_action = act.InputSelector {
  title = 'Select Font (applied immediately)',
  fuzzy = true,
  fuzzy_description = 'Search fonts...',
  choices = font_choices,
  action = wezterm.action_callback(function(window, pane, id)
    if id then
      local overrides = window:get_config_overrides() or {}
      overrides.font = wezterm.font(id)
      window:set_config_overrides(overrides)
    end
  end),
}

---------------------------------------
-- Keybindings (Windows: CTRL based)
---------------------------------------
config.keys = {
  -- F1: Keyboard shortcuts cheatsheet
  { key = 'F1', action = cheatsheet_action },

  -- Smart Palette (replaces default Command Palette)
  {
    key = 'p', mods = 'CTRL|SHIFT',
    action = act.InputSelector {
      title = 'Command Palette',
      fuzzy = true,
      fuzzy_description = 'Search commands...',
      choices = palette_commands,
      action = wezterm.action_callback(function(window, pane, id)
        if not id then return end
        if id == 'theme' then
          window:perform_action(theme_selector_action, pane)
        elseif id == 'font_select' then
          window:perform_action(font_selector_action, pane)
        elseif id == 'cheatsheet' then
          window:perform_action(cheatsheet_action, pane)
        elseif id == 'break_pane' then
          pane:move_to_new_tab()
        elseif palette_actions[id] then
          window:perform_action(palette_actions[id], pane)
        end
      end),
    },
  },

  -- Original Command Palette (backup)
  { key = 'p', mods = 'CTRL|SHIFT|ALT', action = act.ActivateCommandPalette },

  -- Theme / Font selectors
  { key = 'i', mods = 'CTRL|SHIFT', action = theme_selector_action },
  { key = 'o', mods = 'CTRL|SHIFT', action = font_selector_action },

  -- Pane split (inherit current directory)
  { key = 'd', mods = 'CTRL', action = wezterm.action_callback(function(window, pane)
    local new_pane = pane:split { direction = 'Right', domain = 'CurrentPaneDomain', cwd = get_cwd(pane) }
    new_pane:send_text('\x1b')
  end)},
  { key = 'e', mods = 'CTRL|SHIFT', action = wezterm.action_callback(function(window, pane)
    local new_pane = pane:split { direction = 'Bottom', domain = 'CurrentPaneDomain', cwd = get_cwd(pane) }
    new_pane:send_text('\x1b')
  end)},

  -- Pane navigation
  { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'k', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'j', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },

  -- Pane resize
  { key = 'H', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'L', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },

  -- Pane management
  { key = 'z', mods = 'CTRL|SHIFT', action = act.TogglePaneZoomState },
  { key = 's', mods = 'CTRL|SHIFT', action = act.PaneSelect {} },
  { key = 'x', mods = 'CTRL|SHIFT', action = act.PaneSelect { mode = 'SwapWithActive' } },
  { key = 'b', mods = 'CTRL|SHIFT', action = wezterm.action_callback(function(win, pane)
    pane:move_to_new_tab()
  end)},

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

  -- Tab navigation (Ctrl+Tab / Ctrl+Shift+Tab)
  { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },

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

  -- Smart paste (files/images/text detection)
  { key = 'v', mods = 'CTRL|SHIFT', action = smart_paste_action },

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

  -- Launch menu
  { key = 'l', mods = 'CTRL|SHIFT', action = act.ShowLauncherArgs { flags = 'LAUNCH_MENU_ITEMS' } },
}

---------------------------------------
-- Launch Menu
---------------------------------------
config.launch_menu = {
  { label = 'PowerShell 7',   args = { 'pwsh.exe', '-NoLogo' } },
  { label = 'Command Prompt', args = { 'cmd.exe' } },
  { label = 'WSL (Ubuntu)',   args = { 'wsl.exe', '-d', 'Ubuntu' } },
}

---------------------------------------
-- Mouse bindings
-- Left release: auto-copy selection
-- Right-click: smart paste (files/images/text detection)
---------------------------------------
config.mouse_bindings = {
  { event = { Up = { streak = 1, button = 'Left' } }, mods = 'NONE', action = act.CompleteSelection 'ClipboardAndPrimarySelection' },
  { event = { Up = { streak = 2, button = 'Left' } }, mods = 'NONE', action = act.CompleteSelection 'ClipboardAndPrimarySelection' },
  { event = { Up = { streak = 3, button = 'Left' } }, mods = 'NONE', action = act.CompleteSelection 'ClipboardAndPrimarySelection' },
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action_callback(function(window, pane)
      local sel = window:get_selection_text_for_pane(pane)
      if sel and sel ~= '' then
        window:perform_action(act.CopyTo 'Clipboard', pane)
      else
        window:perform_action(act.PasteFrom 'Clipboard', pane)
      end
    end),
  },
}

return config
