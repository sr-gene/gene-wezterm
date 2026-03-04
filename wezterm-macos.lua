local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

---------------------------------------
-- 폰트 설정 (Nerd Font 권장)
---------------------------------------
config.font = wezterm.font('JetBrainsMono NF')
config.font_size = 14.0  -- macOS Retina에 맞게 약간 크게

---------------------------------------
-- 컬러 스킴
---------------------------------------
config.color_scheme = 'Tokyo Night'

---------------------------------------
-- 창 설정
---------------------------------------
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.window_padding = {
  left = 8, right = 8, top = 8, bottom = 8,
}
config.initial_rows = 40
config.initial_cols = 140
config.native_macos_fullscreen_mode = true

---------------------------------------
-- 탭바 설정
---------------------------------------
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false

---------------------------------------
-- 스크롤백
---------------------------------------
config.scrollback_lines = 10000
config.enable_scroll_bar = true

-- 스크롤바 & 탭바 색상
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
-- 한글 IME 설정
---------------------------------------
config.use_ime = true
config.ime_preedit_rendering = 'Builtin'

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
-- Keybindings (macOS: CMD based)
---------------------------------------
config.keys = {
  -- Pane 분할
  { key = 'd', mods = 'CMD', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'e', mods = 'CMD|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- Pane 이동
  { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'k', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'j', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },

  -- Pane 크기 조절
  { key = 'H', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'L', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },

  -- Pane 닫기
  { key = 'w', mods = 'CMD', action = act.CloseCurrentPane { confirm = true } },

  -- 새 탭
  { key = 't', mods = 'CMD', action = act.SpawnTab 'CurrentPaneDomain' },

  -- 복사 / 붙여넣기 (macOS 기본 CMD+C/V 유지)
  { key = 'c', mods = 'CMD', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CMD', action = act.PasteFrom 'Clipboard' },

  -- 스크롤 내비게이션
  { key = 'End', mods = 'CMD', action = act.ScrollToBottom },
  { key = 'Home', mods = 'CMD', action = act.ScrollToTop },
  { key = 'u', mods = 'CMD|ALT', action = act.ScrollByPage(-0.5) },
  { key = 'd', mods = 'CMD|ALT', action = act.ScrollByPage(0.5) },
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
