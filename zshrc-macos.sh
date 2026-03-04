#------------------------------------------
# Oh My Posh 프롬프트
#------------------------------------------
eval "$(oh-my-posh init zsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin_mocha.omp.json)"

#------------------------------------------
# fzf 키바인딩 + 자동완성
#------------------------------------------
source <(fzf --zsh)

#------------------------------------------
# zoxide (z 명령어 — 디렉터리 점프)
#------------------------------------------
eval "$(zoxide init zsh)"

#------------------------------------------
# Alias
#------------------------------------------
alias g='git'
alias ll='ls -la'
alias cc='claude'
alias ccc='claude --continue'

#------------------------------------------
# OSC 7 (WezTerm에 현재 작업 디렉터리 알림)
#------------------------------------------
__wezterm_osc7() {
  printf '\e]7;file://%s%s\e\\' "$HOST" "$PWD"
}
precmd_functions+=(__wezterm_osc7)
