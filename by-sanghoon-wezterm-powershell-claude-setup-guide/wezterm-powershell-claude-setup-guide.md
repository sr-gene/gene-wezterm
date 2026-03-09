# WezTerm + PowerShell 7 + Claude Code 윈도우 설정 가이드

새 윈도우 PC에서 이 가이드를 순서대로 따라하면 동일한 개발 환경이 구성됩니다.

> **필수 조건**: Windows 10/11, winget 사용 가능, Node.js 18+ 설치됨

---

## Step 1. PowerShell 7 설치

```powershell
winget install Microsoft.PowerShell
```

설치 확인 (CMD에서):
```
pwsh --version
```

> PowerShell 5.1(파란 아이콘)과 PowerShell 7(검정 아이콘)은 별개입니다. 이후 모든 작업은 **pwsh**에서 진행합니다.

---

## Step 2. WezTerm 설치

```powershell
winget install wez.wezterm
```

---

## Step 3. Oh My Posh + Nerd Font 설치

```powershell
winget install JanDeDobbeleer.OhMyPosh
```

셸을 닫고 다시 연 뒤 폰트 설치:
```powershell
oh-my-posh font install JetBrainsMono
```

> 관리자 권한 팝업이 뜨면 허용합니다. 설치 후 사용 가능 폰트: `JetBrainsMono NF`

---

## Step 4. 추가 도구 설치

```powershell
winget install junegunn.fzf
winget install sxyazi.yazi
```

---

## Step 5. PowerShell 모듈 설치

**pwsh** (PowerShell 7)에서 실행합니다:

```powershell
Install-Module PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck
Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser -Force
Install-Module posh-git -Scope CurrentUser -Force
Install-Module PSFzf -Scope CurrentUser -Force
Install-Module z -Scope CurrentUser -Force -AllowClobber
```

> "신뢰할 수 없는 리포지토리" 경고가 뜨면 `Y` 입력

---

## Step 6. Claude Code 설치

```powershell
npm install -g @anthropic-ai/claude-code
```

---

## Step 7. 설정 파일 배치

### 7-1. WezTerm 설정 (`%USERPROFILE%\.wezterm.lua`)

아래 내용을 `C:\Users\<사용자명>\.wezterm.lua`로 저장합니다.

```lua
local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

---------------------------------------
-- 개성 설정 영역 (테마/폰트는 여기서 변경!)
-- 주석(--)만 옮기면 바로 적용됩니다
-- 또는 Ctrl+Shift+I(테마) / Ctrl+Shift+O(폰트)로 GUI 선택
---------------------------------------
config.color_scheme = 'Tokyo Night'
-- config.color_scheme = 'Catppuccin Mocha'
-- config.color_scheme = 'One Dark (Gogh)'
-- config.color_scheme = 'Dracula'
-- config.color_scheme = 'Gruvbox dark, medium (base16)'
-- config.color_scheme = 'Nord'
-- config.color_scheme = 'Kanagawa (Gogh)'
-- config.color_scheme = 'rose-pine'
-- config.color_scheme = 'Everforest Dark (Gogh)'
-- config.color_scheme = 'GitHub Dark'

config.font_size = 12.0

---------------------------------------
-- 기본 셸: PowerShell 7
---------------------------------------
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  config.default_prog = { 'pwsh.exe', '-NoLogo' }
end

---------------------------------------
-- 폰트 (한글 폴백 포함)
---------------------------------------
config.font = wezterm.font_with_fallback {
  'JetBrainsMono NF',
  'Malgun Gothic',
}
config.line_height = 1.1

---------------------------------------
-- 창 설정
---------------------------------------
config.window_decorations = 'TITLE|RESIZE'
config.window_close_confirmation = 'AlwaysPrompt'
config.window_padding = {
  left = 8, right = 8, top = 8, bottom = 8,
}
config.initial_rows = 40
config.initial_cols = 140

---------------------------------------
-- 탭바 (브라우저 스타일, 상단)
---------------------------------------
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = true
config.show_tab_index_in_tab_bar = true

config.window_frame = {
  font = wezterm.font_with_fallback { 'JetBrainsMono NF', 'Malgun Gothic' },
  font_size = 10.0,
}

---------------------------------------
-- 스크롤백
---------------------------------------
config.scrollback_lines = 10000
config.enable_scroll_bar = true

---------------------------------------
-- 색상
---------------------------------------
config.colors = {
  scrollbar_thumb = '#888888',
  compose_cursor = '#ff9e64',
}

---------------------------------------
-- 터미널 타입
---------------------------------------
config.term = 'xterm-256color'

---------------------------------------
-- 한글 IME
---------------------------------------
config.use_ime = true
config.ime_preedit_rendering = 'Builtin'

---------------------------------------
-- 마우스 바인딩
-- 블럭 선택 = 자동 복사 / 우클릭 = 붙여넣기
---------------------------------------
---------------------------------------
-- 스마트 붙여넣기 (파일/이미지만 스마트 처리)
-- 클립보드에 파일 목록 → 각 파일의 절대 경로 (따옴표+공백)
-- 클립보드에 이미지 → 임시 파일 저장 후 경로 전달
-- 클립보드에 텍스트 → 기본 붙여넣기 사용 (Claude Code 호환)
---------------------------------------
local smart_paste_action = wezterm.action_callback(function(window, pane)
  local success, stdout = wezterm.run_child_process({
    'powershell.exe', '-NoProfile', '-Command',
    [[Add-Type -AssemblyName System.Windows.Forms; $cb=[System.Windows.Forms.Clipboard]::GetDataObject(); if($cb){if($cb.ContainsFileDropList()){"__FILES__"; ($cb.GetFileDropList()|%{"`"$_`""})-join' '}elseif($cb.ContainsImage()){$img=$cb.GetImage();$p=Join-Path $env:TEMP ("claude_img_"+(Get-Date -Format "yyyyMMdd_HHmmss")+".png");$img.Save($p,[System.Drawing.Imaging.ImageFormat]::Png);"__IMAGE__"; $p}else{"__TEXT__"}}]]
  })
  if success and stdout ~= '' then
    local first_line, rest = stdout:match("^([^\r\n]+)[\r\n]+(.*)")
    if not first_line then
      first_line = stdout:gsub('%s+$', '')
      rest = ''
    end

    if first_line == '__FILES__' or first_line == '__IMAGE__' then
      -- 파일/이미지: send_text로 경로 입력
      pane:send_text(rest:gsub('%s+$', ''))
    else
      -- 텍스트: 기본 WezTerm 붙여넣기 사용 (Claude Code TUI 호환)
      window:perform_action(act.PasteFrom 'Clipboard', pane)
    end
  end
end)

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
-- F1 치트시트 데이터 (보기 전용)
---------------------------------------
local cheatsheet_choices = {
  { label = '-- Tab ----------------------------------' },
  { label = 'Ctrl+Shift+T        새 탭' },
  { label = 'Ctrl+Tab            다음 탭' },
  { label = 'Ctrl+Shift+Tab      이전 탭' },
  { label = 'Ctrl+Shift+W        탭/패널 닫기' },
  { label = '' },
  { label = '-- Panel --------------------------------' },
  { label = 'Ctrl+Shift+D        좌우 분할' },
  { label = 'Ctrl+Shift+E        상하 분할' },
  { label = 'Alt+Arrow            패널 이동' },
  { label = 'Alt+Shift+Arrow     패널 크기 조절' },
  { label = 'Ctrl+Shift+Z        패널 확대/복원' },
  { label = 'Ctrl+Shift+S        패널 번호 선택' },
  { label = 'Ctrl+Shift+X        패널 위치 교체' },
  { label = 'Ctrl+Shift+B        패널 → 새 탭으로 분리' },
  { label = '' },
  { label = '-- Scroll / Search ----------------------' },
  { label = 'Ctrl+Shift+F        텍스트 검색' },
  { label = 'Shift+PageUp/Down   페이지 스크롤' },
  { label = 'Ctrl+Home/End       맨 위/아래' },
  { label = 'Ctrl+Alt+U/D        반 페이지 스크롤' },
  { label = '' },
  { label = '-- Copy / Paste -------------------------' },
  { label = '블럭 선택              자동 복사 (Copy on Select)' },
  { label = '우클릭                  붙여넣기' },
  { label = 'Ctrl+Shift+C        복사' },
  { label = 'Ctrl+Shift+V        붙여넣기' },
  { label = '' },
  { label = '-- Display ------------------------------' },
  { label = 'Ctrl+Shift+=        글자 크게' },
  { label = 'Ctrl+Shift+-        글자 작게' },
  { label = 'Ctrl+Shift+0        글자 초기화' },
  { label = 'Alt+Enter           전체화면' },
  { label = '' },
  { label = '-- Utility ------------------------------' },
  { label = 'Ctrl+Shift+P        Smart Palette' },
  { label = 'Ctrl+Shift+I        테마 변경' },
  { label = 'Ctrl+Shift+O        폰트 변경' },
  { label = 'Ctrl+Shift+L        Launch Menu' },
  { label = 'F1                  이 치트시트' },
}

---------------------------------------
-- Smart Palette 데이터
---------------------------------------
local palette_commands = {
  { id = 'new_tab',      label = '새 탭 열기' },
  { id = 'close',        label = '탭/패널 닫기' },
  { id = 'next_tab',     label = '다음 탭' },
  { id = 'prev_tab',     label = '이전 탭' },
  { id = 'rename_tab',   label = '탭 이름 변경' },
  { id = 'split_h',      label = '패널 좌우 분할' },
  { id = 'split_v',      label = '패널 상하 분할' },
  { id = 'zoom',         label = '패널 확대/복원' },
  { id = 'select_pane',  label = '패널 번호로 선택' },
  { id = 'swap_pane',    label = '패널 위치 교체' },
  { id = 'break_pane',   label = '패널 → 새 탭으로 분리' },
  { id = 'copy',         label = '복사' },
  { id = 'paste',        label = '붙여넣기' },
  { id = 'search',       label = '텍스트 검색' },
  { id = 'copy_mode',    label = 'Copy Mode (Vim식 선택)' },
  { id = 'font_up',      label = '글자 크게' },
  { id = 'font_down',    label = '글자 작게' },
  { id = 'font_reset',   label = '글자 크기 초기화' },
  { id = 'fullscreen',   label = '전체화면 토글' },
  { id = 'theme',        label = '테마 변경' },
  { id = 'font_select',  label = '폰트 변경' },
  { id = 'launch_menu',  label = '셸 선택 (Launch Menu)' },
  { id = 'new_window',   label = '새 창' },
  { id = 'reload',       label = '설정 다시 로드' },
  { id = 'cheatsheet',   label = '단축키 도움말 (F1)' },
}

local palette_actions = {
  new_tab     = act.SpawnTab 'CurrentPaneDomain',
  close       = act.CloseCurrentPane { confirm = true },
  next_tab    = act.ActivateTabRelative(1),
  prev_tab    = act.ActivateTabRelative(-1),
  rename_tab  = act.PromptInputLine {
    description = wezterm.format {
      { Foreground = { AnsiColor = 'Aqua' } },
      { Text = '탭 이름 입력:' },
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
-- 테마 선택기 데이터
---------------------------------------
local theme_choices = {
  { id = 'Tokyo Night',                     label = 'Tokyo Night -- 깔끔한 다크 (기본)' },
  { id = 'Catppuccin Mocha',                label = 'Catppuccin Mocha -- 부드러운 파스텔' },
  { id = 'One Dark (Gogh)',                 label = 'One Dark -- Atom 스타일' },
  { id = 'Dracula',                         label = 'Dracula -- 보라 계열 다크' },
  { id = 'Gruvbox dark, medium (base16)',   label = 'Gruvbox Dark -- 따뜻한 레트로' },
  { id = 'Nord',                            label = 'Nord -- 차가운 북유럽 블루' },
  { id = 'Solarized Dark (Gogh)',           label = 'Solarized Dark -- 클래식' },
  { id = 'Kanagawa (Gogh)',                 label = 'Kanagawa -- 일본풍 다크' },
  { id = 'rose-pine',                       label = 'Rose Pine -- 은은한 핑크' },
  { id = 'Everforest Dark (Gogh)',          label = 'Everforest -- 자연 그린' },
  { id = 'GitHub Dark',                     label = 'GitHub Dark -- GitHub 스타일' },
  { id = 'Material (Gogh)',                 label = 'Material -- Google 머티리얼' },
  { id = 'Nightfox (Gogh)',                 label = 'Nightfox -- 깊은 네이비' },
  { id = 'Ayu Dark (Gogh)',                 label = 'Ayu Dark -- 미니멀' },
}

---------------------------------------
-- 폰트 선택기 데이터
---------------------------------------
local font_choices = {
  { id = 'JetBrainsMono NF',   label = 'JetBrainsMono -- 프로그래밍 특화 (기본)' },
  { id = 'CaskaydiaCove NF',   label = 'Cascadia Code -- MS 공식' },
  { id = 'FiraCode NF',        label = 'Fira Code -- 합자 지원' },
  { id = 'Hack NF',            label = 'Hack -- 가독성 최고' },
  { id = 'MesloLGS NF',        label = 'MesloLGS -- Powerlevel10k 추천' },
  { id = 'SourceCodePro NF',   label = 'Source Code Pro -- Adobe' },
  { id = 'UbuntuMono NF',      label = 'Ubuntu Mono -- 깔끔한 둥근체' },
  { id = 'RobotoMono NF',      label = 'Roboto Mono -- Google' },
}

---------------------------------------
-- 재사용 액션 정의
---------------------------------------
local cheatsheet_action = act.InputSelector {
  title = '  단축키 치트시트  (/ 로 검색)',
  fuzzy = true,
  fuzzy_description = '단축키 검색...',
  choices = cheatsheet_choices,
  action = wezterm.action_callback(function() end),
}

local theme_selector_action = act.InputSelector {
  title = '  테마 선택 (즉시 적용)',
  fuzzy = true,
  fuzzy_description = '테마 검색...',
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
  title = '  폰트 선택 (즉시 적용, 미설치 폰트는 폴백)',
  fuzzy = true,
  fuzzy_description = '폰트 검색...',
  choices = font_choices,
  action = wezterm.action_callback(function(window, pane, id)
    if id then
      local overrides = window:get_config_overrides() or {}
      overrides.font = wezterm.font_with_fallback { id, 'Malgun Gothic' }
      window:set_config_overrides(overrides)
    end
  end),
}

---------------------------------------
-- 키바인딩
---------------------------------------
config.keys = {
  -- F1: 단축키 치트시트
  { key = 'F1', action = cheatsheet_action },

  -- Ctrl+Shift+P: Smart Palette (기본 Command Palette 대체)
  {
    key = 'p', mods = 'CTRL|SHIFT',
    action = act.InputSelector {
      title = '  명령 팔레트',
      fuzzy = true,
      fuzzy_description = '명령 검색...',
      choices = palette_commands,
      action = wezterm.action_callback(function(window, pane, id)
        if not id then return end
        if id == 'theme' then
          window:perform_action(theme_selector_action, pane)
        elseif id == 'font_select' then
          window:perform_action(font_selector_action, pane)
        elseif id == 'cheatsheet' then
          window:perform_action(cheatsheet_action, pane)
        elseif palette_actions[id] then
          window:perform_action(palette_actions[id], pane)
        end
      end),
    },
  },

  -- Ctrl+Shift+Alt+P: 원본 Command Palette (백업)
  { key = 'p', mods = 'CTRL|SHIFT|ALT', action = act.ActivateCommandPalette },

  -- 테마/폰트 직접 접근
  { key = 'i', mods = 'CTRL|SHIFT', action = theme_selector_action },
  { key = 'o', mods = 'CTRL|SHIFT', action = font_selector_action },

  -- 탭
  { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentPane { confirm = true } },
  { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },

  -- 패널 분할
  { key = 'd', mods = 'CTRL|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'e', mods = 'CTRL|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- 패널 이동 (Alt+방향키)
  { key = 'LeftArrow',  mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = 'ALT', action = act.ActivatePaneDirection 'Down' },

  -- 패널 크기 조절 (Alt+Shift+방향키)
  { key = 'LeftArrow',  mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'RightArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },
  { key = 'UpArrow',    mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Up', 3 } },
  { key = 'DownArrow',  mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Down', 3 } },

  -- 패널 관리
  { key = 'z', mods = 'CTRL|SHIFT', action = act.TogglePaneZoomState },
  { key = 's', mods = 'CTRL|SHIFT', action = act.PaneSelect {} },
  { key = 'x', mods = 'CTRL|SHIFT', action = act.PaneSelect { mode = 'SwapWithActive' } },

  -- 패널 → 새 탭으로 분리 (Break Pane)
  {
    key = 'b', mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(function(win, pane)
      pane:move_to_new_tab()
    end),
  },

  -- 복사/붙여넣기
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = smart_paste_action },

  -- 스크롤
  { key = 'End',  mods = 'CTRL', action = act.ScrollToBottom },
  { key = 'Home', mods = 'CTRL', action = act.ScrollToTop },
  { key = 'u', mods = 'CTRL|ALT', action = act.ScrollByPage(-0.5) },
  { key = 'd', mods = 'CTRL|ALT', action = act.ScrollByPage(0.5) },
}

---------------------------------------
-- Launch Menu
---------------------------------------
config.launch_menu = {
  { label = '파워셸 7',      args = { 'pwsh.exe', '-NoLogo' } },
  { label = '명령 프롬프트',  args = { 'cmd.exe' } },
  { label = 'WSL (Ubuntu)',   args = { 'wsl.exe', '-d', 'Ubuntu' } },
}

return config
```

### 7-2. PowerShell 프로필

프로필 경로 확인 및 생성:
```powershell
# pwsh에서 실행
if (!(Test-Path (Split-Path $PROFILE))) {
    New-Item -Path (Split-Path $PROFILE) -ItemType Directory -Force
}
```

아래 내용을 `$PROFILE` 경로 (보통 `C:\Users\<사용자명>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`)에 저장합니다.

```powershell
#------------------------------------------
# Oh My Posh 프롬프트
#------------------------------------------
oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin_mocha.omp.json' | Invoke-Expression

# OSC 7 (Oh My Posh 프롬프트 유지하면서 WezTerm에 CWD 전달)
$_ompPrompt = $function:prompt
function prompt {
    $loc = Get-Location
    if ($loc.Provider.Name -eq "FileSystem") {
        $uri = [uri]::new($loc.Path)
        [Console]::Write("`e]7;file://$($env:COMPUTERNAME)$($uri.AbsolutePath)`e\")
    }
    & $_ompPrompt
}

#------------------------------------------
# PSReadLine
#------------------------------------------
Import-Module PSReadLine
Set-PSReadLineOption -EditMode Windows
try { Set-PSReadLineOption -PredictionSource HistoryAndPlugin } catch {}
try { Set-PSReadLineOption -PredictionViewStyle InlineView } catch {}
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

#------------------------------------------
# Terminal-Icons
#------------------------------------------
Import-Module Terminal-Icons

#------------------------------------------
# posh-git
#------------------------------------------
Import-Module posh-git

#------------------------------------------
# PSFzf (fzf 설치 시 자동 활성화)
#------------------------------------------
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadLineChordProvider 'Ctrl+f' -PSReadLineChordReverseHistory 'Ctrl+r'
}

#------------------------------------------
# z (디렉터리 점프)
#------------------------------------------
Import-Module z

#------------------------------------------
# 최근 디렉토리 히스토리 (시작 시 fzf 선택)
# 셸 시작 시 최근 5개 폴더를 보여주고 선택 가능
#------------------------------------------
$script:RecentDirsFile = "$env:USERPROFILE\.recent_dirs"

# 디렉토리 히스토리에 추가
function Add-RecentDir {
    param([string]$Path)
    # 홈 디렉토리는 제외
    if ($Path -eq $env:USERPROFILE) { return }

    if (!(Test-Path $script:RecentDirsFile)) {
        New-Item -Path $script:RecentDirsFile -ItemType File -Force | Out-Null
    }
    $dirs = @()
    if (Test-Path $script:RecentDirsFile) {
        $dirs = @(Get-Content $script:RecentDirsFile -ErrorAction SilentlyContinue | Where-Object { $_ })
    }
    # 현재 경로 제거 후 맨 앞에 추가 (중복 방지)
    $dirs = @($Path) + ($dirs | Where-Object { $_ -ne $Path })
    # 최대 20개 유지
    $dirs | Select-Object -First 20 | Set-Content $script:RecentDirsFile
}

# Set-Location 래핑하여 디렉토리 변경 추적
$script:OriginalSetLocation = Get-Command Set-Location -CommandType Cmdlet
function Set-Location {
    param(
        [Parameter(Position=0, ValueFromPipeline=$true)]
        [string]$Path
    )
    if ($Path) {
        & $script:OriginalSetLocation $Path
    } else {
        & $script:OriginalSetLocation
    }
    Add-RecentDir (Get-Location).Path
}
Set-Alias -Name cd -Value Set-Location -Option AllScope -Force

# 시작 시 최근 디렉토리 선택 (fzf)
function Show-RecentDirs {
    if (!(Get-Command fzf -ErrorAction SilentlyContinue)) { return }

    $currentDir = (Get-Location).Path
    $recentDirs = @()

    if (Test-Path $script:RecentDirsFile) {
        $recentDirs = Get-Content $script:RecentDirsFile -ErrorAction SilentlyContinue |
                Where-Object { $_ -and (Test-Path $_) -and ($_ -ne $currentDir) } |
                Select-Object -First 19
    }

    # 현재 폴더를 맨 앞에 추가
    $dirs = @("(현재) $currentDir") + ($recentDirs | ForEach-Object { $_ })

    Write-Host "`n최근 작업 폴더 (Enter: 선택, Esc: 취소)`n" -ForegroundColor Cyan
    $selected = $dirs | fzf --prompt="폴더 선택> " --height=7 --reverse --no-sort --ansi
    if ($selected) {
        # "(현재)" 접두사 제거
        if ($selected -match "^\(현재\) (.+)$") {
            $selected = $matches[1]
        }
        & $script:OriginalSetLocation $selected
        Write-Host "→ $selected" -ForegroundColor Green
    }
}

# 셸 시작 시 실행 (진짜 대화형 터미널에서만)
$isRealTerminal = $Host.Name -eq 'ConsoleHost' -and
                  [Environment]::UserInteractive -and
                  -not [Console]::IsInputRedirected -and
                  -not [Console]::IsOutputRedirected

if ($isRealTerminal) {
    Show-RecentDirs
}

#------------------------------------------
# Alias
#------------------------------------------
Set-Alias -Name g -Value git
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name which -Value Get-Command

#------------------------------------------
# Claude Code
#------------------------------------------
function cc { claude }
function ccc { claude --continue }
function ccy { claude --dangerously-skip-permissions }
function ccyo { claude --dangerously-skip-permissions '--model=opus[1m]' }
function ccyc { claude --dangerously-skip-permissions --continue }
function ccyp {
    $prompt = $args -join ' '
    claude -p "$prompt" --dangerously-skip-permissions
}

# 한글 입력 헬퍼 (Claude Code 화면 갱신 중 한글 깨짐 우회)
# 사용법: 다른 패널에서 한글 작성 후 클립보드 복사 → ccp 실행
function ccp {
    $text = Get-Clipboard
    if ($text) { claude -p $text }
    else { Write-Host "클립보드가 비어있습니다." }
}

#------------------------------------------
# yazi 래퍼 (종료 시 디렉터리 동기화)
#------------------------------------------
if (Get-Command yazi -ErrorAction SilentlyContinue) {
    function y {
        $tmp = [System.IO.Path]::GetTempFileName()
        yazi $args --cwd-file="$tmp"
        $cwd = Get-Content $tmp -ErrorAction SilentlyContinue
        if ($cwd -and $cwd -ne $PWD.Path) {
            Set-Location $cwd
        }
        Remove-Item $tmp -ErrorAction SilentlyContinue
    }
}
```

### 7-3. Claude Code 설정 (`%USERPROFILE%\.claude\settings.json`)

작업 완료 알림 소리를 위한 hook 설정입니다. `C:\Users\<사용자명>\.claude\settings.json`에 저장합니다.

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "powershell.exe -c \"(New-Object Media.SoundPlayer 'C:\\Windows\\Media\\chimes.wav').PlaySync()\""
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "powershell.exe -c \"(New-Object Media.SoundPlayer 'C:\\Windows\\Media\\chimes.wav').PlaySync()\""
          }
        ]
      }
    ]
  }
}
```

> 주의: Claude Code의 hook은 bash 셸에서 실행됩니다. PowerShell 명령은 반드시 `powershell.exe -c "..."` 형태로 감싸야 합니다.

---

## Step 8. 설정 확인

WezTerm을 닫고 다시 실행한 뒤, 아래를 확인합니다.

### 시각 확인
- [ ] 상단에 브라우저 스타일 탭바가 보이는가
- [ ] Tokyo Night 다크 테마가 적용되었는가
- [ ] Oh My Posh 프롬프트 (catppuccin_mocha)가 보이는가
- [ ] `ll` 실행 시 파일/폴더에 아이콘이 표시되는가

### 기능 확인
- [ ] `F1` → 단축키 치트시트 팝업
- [ ] `Ctrl+Shift+P` → Smart Palette (한글 명령 목록)
- [ ] `Ctrl+Shift+D` → 좌우 패널 분할
- [ ] `Ctrl+Shift+I` → 테마 선택기
- [ ] 우클릭 → 붙여넣기 (선택 없을 때)
- [ ] 창 닫기 시 확인 모달 표시

### 명령어 확인
```powershell
# 도구 확인
pwsh --version          # PowerShell 7.x
oh-my-posh --version    # 29.x
fzf --version           # 0.x
yazi --version          # 26.x
claude --version        # Claude Code

# 별칭 확인
cc                      # Claude Code 시작
ccy                     # YOLO 모드 시작
y                       # yazi 파일 매니저
```

---

## 단축키 요약

### 탭
| 동작 | 단축키 |
|------|--------|
| 새 탭 | `Ctrl+Shift+T` 또는 탭바 `+` 버튼 |
| 탭 닫기 | `Ctrl+Shift+W` 또는 탭 `X` 버튼 |
| 다음/이전 탭 | `Ctrl+Tab` / `Ctrl+Shift+Tab` |

### 패널
| 동작 | 단축키 |
|------|--------|
| 좌우 분할 | `Ctrl+Shift+D` |
| 상하 분할 | `Ctrl+Shift+E` |
| 패널 이동 | `Alt+방향키` |
| 패널 크기 조절 | `Alt+Shift+방향키` |
| 패널 확대/복원 | `Ctrl+Shift+Z` |
| 패널 번호 선택 | `Ctrl+Shift+S` |
| 패널 위치 교체 | `Ctrl+Shift+X` |
| 패널 → 새 탭 분리 | `Ctrl+Shift+B` |

### 유틸리티
| 동작 | 단축키 |
|------|--------|
| 단축키 치트시트 | `F1` |
| Smart Palette | `Ctrl+Shift+P` |
| 테마 변경 | `Ctrl+Shift+I` |
| 폰트 변경 | `Ctrl+Shift+O` |
| 텍스트 검색 | `Ctrl+Shift+F` |
| Launch Menu | `Ctrl+Shift+L` |

### 마우스
| 동작 | 조작 |
|------|------|
| 복사 | 텍스트 블럭 선택 (자동 복사) |
| 붙여넣기 | 우클릭 또는 `Ctrl+Shift+V` |

---

## 스마트 붙여넣기

`Ctrl+Shift+V` 또는 우클릭 시 클립보드 내용을 자동 감지하여 적절히 처리합니다.

| 클립보드 내용 | 붙여넣기 결과 |
|--------------|--------------|
| 파일 목록 (탐색기에서 복사) | `"경로1" "경로2" ...` (따옴표+공백 구분) |
| 이미지 (스크린샷 등) | 임시 PNG 파일 경로 (`%TEMP%\claude_img_*.png`) |
| 텍스트 | 기본 WezTerm 붙여넣기 (Claude Code TUI 호환) |

> **참고**: 텍스트는 Claude Code와의 호환성을 위해 WezTerm 기본 붙여넣기를 사용합니다. 일부 TUI 앱에서 bracketed paste가 동작하지 않는 문제를 방지합니다.

### 사용 예시
파일 탐색기에서 3개 파일 선택 → `Ctrl+C` → WezTerm에서 붙여넣기:
```
"C:\Users\Sanghun\Documents\file1.txt" "C:\path with spaces\file2.pdf" "C:\Downloads\image.png"
```

> 경로에 공백이 있어도 따옴표로 감싸져 있어 명령줄 인자로 바로 사용 가능

---

## 최근 작업 폴더 (시작 시 선택)

WezTerm 새 탭/창을 열면 fzf로 폴더 선택 UI가 표시됩니다.

- **첫 번째 항목은 현재 폴더** - `(현재) C:\...` 형태로 표시
- **Enter만 누르면 현재 폴더에서 바로 시작** - 과거 폴더 선택 없이 빠르게 진행
- 나머지는 최근 작업했던 폴더들 (최대 19개)

| 동작 | 키 |
|------|-----|
| 폴더 선택 | `↑/↓` 또는 타이핑 |
| 선택 확정 | `Enter` |
| 취소 | `Esc` |

### 수동 호출
```powershell
Show-RecentDirs   # 언제든 최근 폴더 선택 UI 호출
```

### 히스토리 파일
- 위치: `~/.recent_dirs`
- 최대 20개 저장, 중복 자동 제거
- 홈 디렉토리는 자동 제외

---

## Claude Code 별칭

| 별칭 | 명령 | 설명 |
|------|------|------|
| `cc` | `claude` | 기본 실행 |
| `ccc` | `claude --continue` | 이전 세션 이어서 |
| `ccy` | `claude --dangerously-skip-permissions` | YOLO 모드 |
| `ccyo` | `claude --dangerously-skip-permissions --model=opus[1m]` | YOLO + Opus 1M |
| `ccyc` | `claude --dangerously-skip-permissions --continue` | YOLO + 이어서 |
| `ccyp 프롬프트` | `claude -p "..." --dangerously-skip-permissions` | 비대화형 YOLO |
| `ccp` | 클립보드 → claude -p | 한글 입력 헬퍼 |

---

## Claude Code 한글 입력 문제 우회

Claude Code가 화면을 갱신하는 동안 한글 IME 조합이 깨지는 현상은 Claude Code의 TUI 프레임워크 제한입니다. 우회 방법:

1. **패널 분할 방식 (추천)**: `Ctrl+Shift+D`로 패널을 분할하고, 한쪽에서 한글 프롬프트 작성 → 복사 → Claude Code 패널에 붙여넣기
2. **ccp 함수**: 다른 곳에서 한글 텍스트를 복사한 뒤 `ccp` 실행
3. **Esc 후 입력**: Claude Code 출력 중 `Esc`로 멈춘 뒤 한글 입력

---

## 문제 해결

| 증상 | 해결 |
|------|------|
| WezTerm에서 pwsh 대신 Windows PowerShell이 열림 | `where pwsh`로 경로 확인. 없으면 Step 1 재실행 |
| 폰트가 깨짐 (네모 박스) | Step 3의 Nerd Font 설치 확인. WezTerm 완전 종료 후 재시작 |
| Oh My Posh 프롬프트가 안 보임 | `$PROFILE` 경로 확인: `$PROFILE` 실행 후 파일 존재 여부 |
| 모듈 설치 시 권한 오류 | `-Scope CurrentUser` 붙었는지 확인 |
| z 모듈 설치 시 충돌 경고 | `-AllowClobber` 추가 |
| hook 알림 소리 안 남 | `settings.json`에서 `powershell.exe -c "..."` 따옴표 확인 |
| fzf/yazi가 PATH에 없음 | 셸을 완전히 닫고 새로 열기 (PATH 갱신 필요) |
| `$PROFILE`이 없다고 나옴 | `New-Item -Path $PROFILE -ItemType File -Force` |
