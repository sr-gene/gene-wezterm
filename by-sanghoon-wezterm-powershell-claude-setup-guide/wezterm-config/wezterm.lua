local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

---------------------------------------
-- 기본 셸: PowerShell 7
---------------------------------------
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  config.default_prog = { 'pwsh.exe', '-NoLogo' }
end

-- =============================================
-- ★★★ 개성 설정 영역 — 여기만 바꾸면 됩니다 ★★★
-- =============================================

---------------------------------------
-- 🎨 컬러 테마 선택 (하나만 주석 해제)
-- Ctrl+Shift+I 로 GUI에서도 변경 가능!
---------------------------------------
-- ■ 다크 테마
config.color_scheme = 'Tokyo Night'           -- 차분한 파란색 (기본)
-- config.color_scheme = 'Catppuccin Mocha'   -- 부드러운 파스텔
-- config.color_scheme = 'One Dark (Gogh)'    -- VS Code 느낌
-- config.color_scheme = 'Dracula'            -- 보라톤 클래식
-- config.color_scheme = 'Gruvbox dark, hard (base16)'  -- 따뜻한 레트로
-- config.color_scheme = 'Nord (Gogh)'        -- 차가운 블루
-- config.color_scheme = 'rose-pine-moon'     -- 분홍빛 다크
-- config.color_scheme = 'Kanagawa (Gogh)'    -- 일본풍 다크
-- config.color_scheme = 'GitHub Dark'        -- GitHub 스타일
-- config.color_scheme = 'Solarized Dark (Gogh)'  -- 클래식 다크

-- ■ 라이트 테마
-- config.color_scheme = 'Catppuccin Latte'        -- 파스텔 라이트
-- config.color_scheme = 'Solarized Light (Gogh)'  -- 클래식 라이트
-- config.color_scheme = 'GitHub Light'             -- GitHub 라이트
-- config.color_scheme = 'rose-pine-dawn'           -- 분홍빛 라이트

---------------------------------------
-- 🔤 폰트 선택 (하나만 주석 해제)
-- Ctrl+Shift+O 로 GUI에서도 변경 가능!
---------------------------------------
local PRIMARY_FONT = 'JetBrainsMono NF'      -- Nerd Font 아이콘 지원 (기본)
-- local PRIMARY_FONT = 'CaskaydiaCove NF'    -- Windows Terminal 기본
-- local PRIMARY_FONT = 'FiraCode NF'         -- 리가처가 예쁜 폰트
-- local PRIMARY_FONT = 'Hack NF'             -- 깔끔한 고전 코딩
-- local PRIMARY_FONT = 'D2Coding'            -- ★ 한글 코딩 전용 (네이버)
-- local PRIMARY_FONT = 'NanumGothicCoding'   -- ★ 한글 코딩 전용
-- local PRIMARY_FONT = 'Consolas'            -- Windows 기본

-- 한글 폴백 폰트
local KOREAN_FONT = 'Malgun Gothic'           -- 맑은 고딕 (Windows 내장)
-- local KOREAN_FONT = 'NanumGothic'          -- 나눔고딕 (별도 설치)

-- 폰트 크기
config.font_size = 12.0

-- =============================================
-- ★★★ 개성 설정 영역 끝 ★★★
-- =============================================

---------------------------------------
-- 폰트 적용
---------------------------------------
config.font = wezterm.font_with_fallback {
  PRIMARY_FONT,
  { family = KOREAN_FONT, scale = 1.1 },
  'Noto Color Emoji',
}
config.treat_east_asian_ambiguous_width_as_wide = false
config.line_height = 1.1

---------------------------------------
-- GUI 선택기 데이터
---------------------------------------
local FAVORITE_THEMES = {
  { id = 'Tokyo Night',           label = '🌃 Tokyo Night — 차분한 파란색 다크' },
  { id = 'Catppuccin Mocha',      label = '🐱 Catppuccin Mocha — 부드러운 파스텔 다크' },
  { id = 'One Dark (Gogh)',       label = '🌑 One Dark — VS Code 느낌' },
  { id = 'Dracula',               label = '🧛 Dracula — 보라톤 클래식' },
  { id = 'Gruvbox dark, hard (base16)', label = '🟤 Gruvbox Dark — 따뜻한 레트로' },
  { id = 'Nord (Gogh)',           label = '❄️  Nord — 차가운 블루' },
  { id = 'rose-pine-moon',        label = '🌙 Rosé Pine Moon — 분홍빛 다크' },
  { id = 'Kanagawa (Gogh)',       label = '🌊 Kanagawa — 일본풍 다크' },
  { id = 'GitHub Dark',           label = '🐙 GitHub Dark' },
  { id = 'Solarized Dark (Gogh)', label = '☀️  Solarized Dark' },
  { id = 'Catppuccin Latte',      label = '☕ Catppuccin Latte — 파스텔 라이트' },
  { id = 'Solarized Light (Gogh)',label = '🌤️  Solarized Light — 클래식 라이트' },
  { id = 'GitHub Light',          label = '🐙 GitHub Light — 라이트' },
  { id = 'rose-pine-dawn',        label = '🌅 Rosé Pine Dawn — 분홍빛 라이트' },
}

local FAVORITE_FONTS = {
  { id = 'JetBrainsMono NF',       label = '🔤 JetBrains Mono NF — 기본, Nerd Font 아이콘' },
  { id = 'JetBrainsMono Nerd Font', label = '🔤 JetBrains Mono Nerd Font (이름 다를 때)' },
  { id = 'CaskaydiaCove NF',       label = '🔤 Cascadia Code NF — Windows Terminal 스타일' },
  { id = 'FiraCode NF',            label = '🔤 Fira Code NF — 예쁜 리가처' },
  { id = 'Hack NF',                label = '🔤 Hack NF — 깔끔한 고전' },
  { id = 'D2Coding',               label = '🇰🇷 D2코딩 — 한글 코딩 전용 (네이버)' },
  { id = 'NanumGothicCoding',      label = '🇰🇷 나눔고딕코딩 — 한글 코딩 전용' },
  { id = 'Consolas',               label = '🪟 Consolas — Windows 기본' },
}

---------------------------------------
-- 한글 IME 설정
---------------------------------------
config.use_ime = true
config.ime_preedit_rendering = 'Builtin'

config.colors = {
  scrollbar_thumb = '#888888',
  compose_cursor = '#ff9e64',
}

---------------------------------------
-- 상태바: 한글 조합 상태 표시
---------------------------------------
wezterm.on('update-right-status', function(window, pane)
  local compose = window:composition_status()
  if compose then
    window:set_right_status(
      wezterm.format {
        { Foreground = { Color = '#ff9e64' } },
        { Text = ' 입력 중: ' .. compose .. ' ' },
      }
    )
  else
    window:set_right_status('')
  end
end)

---------------------------------------
-- ★ 창 닫기 확인 (실수로 닫기 방지)
---------------------------------------
config.window_close_confirmation = 'AlwaysPrompt'

---------------------------------------
-- 윈도우 스타일 창 설정
---------------------------------------
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.window_padding = {
  left = 8, right = 8, top = 8, bottom = 8,
}
config.initial_rows = 40
config.initial_cols = 140

---------------------------------------
-- 윈도우 스타일 탭바
---------------------------------------
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 25
config.show_new_tab_button_in_tab_bar = true

config.window_frame = {
  font = wezterm.font_with_fallback {
    { family = 'Segoe UI', weight = 'Regular' },
    'Malgun Gothic',
  },
  font_size = 11.0,
  active_titlebar_bg = '#1a1b26',
  inactive_titlebar_bg = '#16161e',
}

---------------------------------------
-- 스마트 붙여넣기 (파일/이미지만 스마트 처리)
-- 클립보드에 파일 목록 → 각 파일의 절대 경로 (따옴표+공백)
-- 클립보드에 이미지 → 임시 파일 저장 후 경로 전달
-- 클립보드에 텍스트 → 기본 붙여넣기 사용 (Claude Code 호환)
---------------------------------------
local smart_paste_action = wezterm.action_callback(function(window, pane)
  -- 기본 붙여넣기 (fallback)
  local function fallback_paste()
    window:perform_action(act.PasteFrom 'Clipboard', pane)
  end

  -- 외부 스크립트로 클립보드 타입 감지 (UTF-8 인코딩 지원)
  local success, stdout = wezterm.run_child_process({
    'powershell.exe', '-NoProfile', '-ExecutionPolicy', 'Bypass',
    '-File', 'C:\\Users\\Sanghun\\.wezterm_clipboard.ps1'
  })

  -- 스크립트 실패 시 기본 붙여넣기
  if not success or not stdout or stdout == '' then
    fallback_paste()
    return
  end

  -- 출력 파싱: 첫 줄 = 타입, 나머지 = 경로
  local first_line, rest = stdout:match("^([^\r\n]+)[\r\n]+(.*)")
  if not first_line then
    first_line = stdout:gsub('%s+$', '')
    rest = ''
  end

  if first_line == '__FILES__' or first_line == '__IMAGE__' then
    -- 파일/이미지: 경로를 텍스트로 입력
    local path = rest:gsub('^%s+', ''):gsub('%s+$', '')
    if path and path ~= '' then
      pane:send_text(path)
    else
      fallback_paste()
    end
  else
    -- 텍스트: 기본 붙여넣기
    fallback_paste()
  end
end)

---------------------------------------
-- 마우스 바인딩
-- 블럭 선택 = 자동 복사 / 우클릭 = 스마트 붙여넣기
---------------------------------------
config.mouse_bindings = {
  -- 블럭 선택 시 자동 복사 (Copy on Select)
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection',
  },
  {
    event = { Up = { streak = 2, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection',
  },
  {
    event = { Up = { streak = 3, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection',
  },
  -- 우클릭: 스마트 붙여넣기 (이미지 자동 감지)
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = smart_paste_action,
  },
}

---------------------------------------
-- Launch Menu (한글)
---------------------------------------
config.launch_menu = {
  { label = '⚡ 파워셸 7 (PowerShell)',   args = { 'pwsh.exe', '-NoLogo' } },
  { label = '📁 명령 프롬프트 (CMD)',       args = { 'cmd.exe' } },
  { label = '🐧 WSL (Ubuntu)',            args = { 'wsl.exe', '-d', 'Ubuntu' } },
}

---------------------------------------
-- 스크롤백 / 기타
---------------------------------------
config.scrollback_lines = 10000
config.enable_scroll_bar = true
config.term = 'xterm-256color'

---------------------------------------
-- ★ 명령 팔레트 한글화 (augment-command-palette)
-- Ctrl+Shift+P 에서 한글로 검색 가능!
-- 예: "새탭", "분할", "복사", "테마" 등
---------------------------------------
wezterm.on('augment-command-palette', function(window, pane)
  return {
    -- ── 탭 ──
    {
      brief = '새 탭 열기 (New Tab)',
      icon = 'md_tab_plus',
      action = act.SpawnTab 'CurrentPaneDomain',
    },
    {
      brief = '탭 닫기 (Close Tab)',
      icon = 'md_tab_remove',
      action = act.CloseCurrentTab { confirm = true },
    },
    {
      brief = '다음 탭 (Next Tab)',
      icon = 'md_arrow_right',
      action = act.ActivateTabRelative(1),
    },
    {
      brief = '이전 탭 (Previous Tab)',
      icon = 'md_arrow_left',
      action = act.ActivateTabRelative(-1),
    },
    {
      brief = '탭 이름 변경 (Rename Tab)',
      icon = 'md_rename_box',
      action = act.PromptInputLine {
        description = '새 탭 이름을 입력하세요:',
        action = wezterm.action_callback(function(w, p, line)
          if line then w:active_tab():set_title(line) end
        end),
      },
    },
    -- ── 화면 분할 ──
    {
      brief = '좌우 분할 (Split Horizontal)',
      icon = 'md_arrow_split_vertical',
      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
      brief = '상하 분할 (Split Vertical)',
      icon = 'md_arrow_split_horizontal',
      action = act.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    {
      brief = '패널 닫기 (Close Pane)',
      icon = 'md_close',
      action = act.CloseCurrentPane { confirm = true },
    },
    -- ── 패널 관리 ──
    {
      brief = '패널 확대/복원 (Zoom Pane Toggle)',
      icon = 'md_arrow_expand_all',
      action = act.TogglePaneZoomState,
    },
    {
      brief = '패널 위치 교체 — 시계방향 (Rotate Panes)',
      icon = 'md_rotate_right',
      action = act.RotatePanes 'Clockwise',
    },
    {
      brief = '패널 위치 교체 — 반시계방향',
      icon = 'md_rotate_left',
      action = act.RotatePanes 'CounterClockwise',
    },
    {
      brief = '패널 선택 (Select Pane)',
      icon = 'md_select',
      action = act.PaneSelect {},
    },
    {
      brief = '패널 위치 맞바꾸기 (Swap Panes)',
      icon = 'md_swap_horizontal',
      action = act.PaneSelect { mode = 'SwapWithActive' },
    },
    -- ── 패널 이동 ──
    {
      brief = '왼쪽 패널로 이동',
      icon = 'md_arrow_left_bold',
      action = act.ActivatePaneDirection 'Left',
    },
    {
      brief = '오른쪽 패널로 이동',
      icon = 'md_arrow_right_bold',
      action = act.ActivatePaneDirection 'Right',
    },
    {
      brief = '위쪽 패널로 이동',
      icon = 'md_arrow_up_bold',
      action = act.ActivatePaneDirection 'Up',
    },
    {
      brief = '아래쪽 패널로 이동',
      icon = 'md_arrow_down_bold',
      action = act.ActivatePaneDirection 'Down',
    },
    -- ── 복사 / 붙여넣기 ──
    {
      brief = '복사 (Copy)',
      icon = 'md_content_copy',
      action = act.CopyTo 'Clipboard',
    },
    {
      brief = '붙여넣기 (Paste)',
      icon = 'md_content_paste',
      action = act.PasteFrom 'Clipboard',
    },
    -- ── 검색 ──
    {
      brief = '검색 (Search)',
      icon = 'md_magnify',
      action = act.Search { CaseInSensitiveString = '' },
    },
    -- ── 스크롤 ──
    {
      brief = '맨 위로 스크롤 (Scroll to Top)',
      icon = 'md_arrow_collapse_up',
      action = act.ScrollToTop,
    },
    {
      brief = '맨 아래로 스크롤 (Scroll to Bottom)',
      icon = 'md_arrow_collapse_down',
      action = act.ScrollToBottom,
    },
    -- ── 폰트 크기 ──
    {
      brief = '글자 크게 (Increase Font Size)',
      icon = 'md_format_font_size_increase',
      action = act.IncreaseFontSize,
    },
    {
      brief = '글자 작게 (Decrease Font Size)',
      icon = 'md_format_font_size_decrease',
      action = act.DecreaseFontSize,
    },
    {
      brief = '글자 크기 초기화 (Reset Font Size)',
      icon = 'md_format_size',
      action = act.ResetFontSize,
    },
    -- ── 테마 / 폰트 선택기 ──
    {
      brief = '🎨 테마 변경 (Change Theme)',
      icon = 'md_palette',
      action = wezterm.action_callback(function(window, pane)
        local choices = {}
        for _, t in ipairs(FAVORITE_THEMES) do
          table.insert(choices, { id = t.id, label = t.label })
        end
        table.insert(choices, { id = '__SEP__', label = '─────────────────────────────' })
        table.insert(choices, { id = '__ALL__', label = '🔍 전체 테마 검색 (700+개)...' })
        window:perform_action(
          act.InputSelector {
            title = '🎨 컬러 테마 선택',
            choices = choices,
            fuzzy = true,
            fuzzy_description = '테마 이름 입력:',
            action = wezterm.action_callback(function(iw, ip, id, label)
              if not id or id == '__SEP__' then return end
              if id == '__ALL__' then
                local all = wezterm.get_builtin_color_schemes()
                local ac = {}
                for name, _ in pairs(all) do table.insert(ac, { label = name }) end
                table.sort(ac, function(a, b) return a.label < b.label end)
                iw:perform_action(
                  act.InputSelector {
                    title = '🎨 전체 테마 (700+개)',
                    choices = ac, fuzzy = true,
                    action = wezterm.action_callback(function(w, _, _, n)
                      if n then w:set_config_overrides { color_scheme = n } end
                    end),
                  }, ip)
              else
                iw:set_config_overrides { color_scheme = id }
              end
            end),
          }, pane)
      end),
    },
    {
      brief = '🔤 폰트 변경 (Change Font)',
      icon = 'md_format_font',
      action = wezterm.action_callback(function(window, pane)
        local choices = {}
        for _, f in ipairs(FAVORITE_FONTS) do
          table.insert(choices, { id = f.id, label = f.label })
        end
        window:perform_action(
          act.InputSelector {
            title = '🔤 폰트 선택',
            choices = choices, fuzzy = true,
            action = wezterm.action_callback(function(iw, _, id, _)
              if not id then return end
              iw:set_config_overrides {
                font = wezterm.font_with_fallback {
                  id, { family = KOREAN_FONT, scale = 1.1 }, 'Noto Color Emoji',
                },
              }
            end),
          }, pane)
      end),
    },
    -- ── 셸 선택 ──
    {
      brief = '셸 선택 메뉴 (Launch Menu)',
      icon = 'md_console',
      action = act.ShowLauncher,
    },
    -- ── 전체화면 ──
    {
      brief = '전체화면 토글 (Toggle Fullscreen)',
      icon = 'md_fullscreen',
      action = act.ToggleFullScreen,
    },
    -- ── 디버그 ──
    {
      brief = '디버그 오버레이 (Debug Overlay)',
      icon = 'md_bug',
      action = act.ShowDebugOverlay,
    },
    -- ── 설정 ──
    {
      brief = '설정 파일 열기 (Open Config)',
      icon = 'md_cog',
      action = act.SpawnCommandInNewTab {
        args = { 'notepad.exe', wezterm.config_file },
      },
    },
    {
      brief = '설정 다시 로드 (Reload Config)',
      icon = 'md_refresh',
      action = act.ReloadConfiguration,
    },
  }
end)

---------------------------------------
-- 키바인딩
---------------------------------------
config.keys = {
  -- 명령 팔레트
  { key = 'p', mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },

  -- 테마 선택기
  {
    key = 'i',
    mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(function(window, pane)
      local choices = {}
      for _, t in ipairs(FAVORITE_THEMES) do
        table.insert(choices, { id = t.id, label = t.label })
      end
      table.insert(choices, { id = '__SEP__', label = '─────────────────────────────' })
      table.insert(choices, { id = '__ALL__', label = '🔍 전체 테마 검색 (700+개)...' })
      window:perform_action(
        act.InputSelector {
          title = '🎨 컬러 테마 선택',
          choices = choices,
          fuzzy = true,
          fuzzy_description = '테마 이름 입력 (한글/영문):',
          action = wezterm.action_callback(function(iw, ip, id, label)
            if not id or id == '__SEP__' then return end
            if id == '__ALL__' then
              local all = wezterm.get_builtin_color_schemes()
              local ac = {}
              for name, _ in pairs(all) do table.insert(ac, { label = name }) end
              table.sort(ac, function(a, b) return a.label < b.label end)
              iw:perform_action(
                act.InputSelector {
                  title = '🎨 전체 테마 (700+개)',
                  choices = ac, fuzzy = true,
                  fuzzy_description = '테마 이름 입력:',
                  action = wezterm.action_callback(function(w, _, _, n)
                    if n then w:set_config_overrides { color_scheme = n } end
                  end),
                }, ip)
            else
              iw:set_config_overrides { color_scheme = id }
            end
          end),
        }, pane)
    end),
  },

  -- 폰트 선택기
  {
    key = 'o',
    mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(function(window, pane)
      local choices = {}
      for _, f in ipairs(FAVORITE_FONTS) do
        table.insert(choices, { id = f.id, label = f.label })
      end
      window:perform_action(
        act.InputSelector {
          title = '🔤 폰트 선택',
          choices = choices, fuzzy = true,
          fuzzy_description = '폰트 이름 입력:',
          action = wezterm.action_callback(function(iw, _, id, _)
            if not id then return end
            iw:set_config_overrides {
              font = wezterm.font_with_fallback {
                id, { family = KOREAN_FONT, scale = 1.1 }, 'Noto Color Emoji',
              },
            }
          end),
        }, pane)
    end),
  },

  -- 탭
  { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = '1', mods = 'ALT', action = act.ActivateTab(0) },
  { key = '2', mods = 'ALT', action = act.ActivateTab(1) },
  { key = '3', mods = 'ALT', action = act.ActivateTab(2) },
  { key = '4', mods = 'ALT', action = act.ActivateTab(3) },
  { key = '5', mods = 'ALT', action = act.ActivateTab(4) },

  -- 셸 메뉴
  { key = 'l', mods = 'CTRL|SHIFT', action = act.ShowLauncher },

  -- 화면 분할
  { key = 'd', mods = 'CTRL|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'e', mods = 'CTRL|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- 패널 이동/크기
  { key = 'LeftArrow',  mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
  { key = 'LeftArrow',  mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'RightArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },
  { key = 'UpArrow',    mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Up', 5 } },
  { key = 'DownArrow',  mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Down', 5 } },

  -- 패널 확대/복원 (하나의 패널을 탭 전체로 확대, 다시 누르면 원래대로)
  { key = 'z', mods = 'CTRL|SHIFT', action = act.TogglePaneZoomState },

  -- 패널 선택 (번호로 패널 고르기)
  { key = 's', mods = 'CTRL|SHIFT', action = act.PaneSelect {} },

  -- 패널 위치 맞바꾸기 (번호로 선택 후 현재 패널과 교체)
  { key = 'x', mods = 'CTRL|SHIFT', action = act.PaneSelect { mode = 'SwapWithActive' } },

  -- 패널 닫기 / 복붙 / 스크롤 / 폰트크기 / 검색
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentPane { confirm = true } },
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = smart_paste_action },
  { key = 'End',  mods = 'CTRL', action = act.ScrollToBottom },
  { key = 'Home', mods = 'CTRL', action = act.ScrollToTop },
  { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
  { key = '0', mods = 'CTRL', action = act.ResetFontSize },
  { key = 'f', mods = 'CTRL|SHIFT', action = act.Search { CaseInSensitiveString = '' } },
}

---------------------------------------
-- 탭 제목
---------------------------------------
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local title = tab.active_pane.title
  if #title > max_width - 3 then
    title = string.sub(title, 1, max_width - 5) .. '…'
  end
  return { { Text = ' ' .. title .. ' ' } }
end)

return config