#!/usr/bin/env bash
# Terminal setup installer — zsh + oh-my-zsh(agnoster) + ghostty + fonts
# Run on a fresh Mac:  bash install.sh

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_USER="seyeong"

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; BLUE=$'\033[0;34m'; NC=$'\033[0m'

info()  { printf "%s[info]%s %s\n"  "$BLUE"   "$NC" "$*"; }
ok()    { printf "%s[ ok ]%s %s\n"  "$GREEN"  "$NC" "$*"; }
warn()  { printf "%s[warn]%s %s\n"  "$YELLOW" "$NC" "$*"; }
err()   { printf "%s[fail]%s %s\n"  "$RED"    "$NC" "$*"; }

ask() {
  # ask "message" [default-y|default-n]
  local msg="$1" def="${2:-y}" prompt reply
  case "$def" in y) prompt="[Y/n]";; n) prompt="[y/N]";; esac
  printf "%s?%s %s %s " "$YELLOW" "$NC" "$msg" "$prompt"
  read -r reply
  reply="${reply:-$def}"
  [[ "$reply" =~ ^[Yy]$ ]]
}

step() { printf "\n%s==>%s %s\n" "$BLUE" "$NC" "$*"; }

# -------------------- 1. Xcode Command Line Tools --------------------
step "1/8  Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
  ok "already installed"
elif ask "install Xcode CLT?"; then
  xcode-select --install || true
  warn "GUI popup으로 설치 진행. 끝나면 Enter."
  read -r
fi

# -------------------- 2. Homebrew --------------------
step "2/8  Homebrew"
if command -v brew >/dev/null 2>&1; then
  ok "already installed at $(command -v brew)"
elif ask "install Homebrew?"; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# -------------------- 3. Oh My Zsh --------------------
step "3/8  Oh My Zsh"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  ok "already installed"
elif ask "install Oh My Zsh (agnoster theme)?"; then
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# -------------------- 4. brew packages + fonts --------------------
step "4/8  brew formulae & fonts"
BREW_FORMULAE=(zsh-syntax-highlighting fastfetch pyenv nvm)
BREW_CASKS=(font-jetbrains-mono-nerd-font ghostty)

if ask "install brew formulae (${BREW_FORMULAE[*]})?"; then
  for pkg in "${BREW_FORMULAE[@]}"; do
    if brew list --formula "$pkg" >/dev/null 2>&1; then
      ok "$pkg already installed"
    else
      brew install "$pkg"
    fi
  done
fi

if ask "install brew casks (${BREW_CASKS[*]})?"; then
  for pkg in "${BREW_CASKS[@]}"; do
    if brew list --cask "$pkg" >/dev/null 2>&1; then
      ok "$pkg already installed"
    else
      brew install --cask "$pkg"
    fi
  done
fi

# -------------------- 5. pokemon-colorscripts (manual) --------------------
step "5/8  pokemon-colorscripts"
if command -v pokemon-colorscripts >/dev/null 2>&1; then
  ok "already installed at $(command -v pokemon-colorscripts)"
elif ask "install pokemon-colorscripts (manual, needs sudo)?"; then
  tmp="$(mktemp -d)"
  git clone --depth 1 https://gitlab.com/phoneybadger/pokemon-colorscripts.git "$tmp"
  (cd "$tmp" && sudo ./install.sh)
  rm -rf "$tmp"
fi

# -------------------- 6. Ghostty config --------------------
step "6/8  Ghostty config (font + cursor shaders)"
if ask "install Ghostty config & cursor shaders?"; then
  mkdir -p "$HOME/.config/ghostty"
  if [[ ! -d "$HOME/.config/ghostty/shaders" ]]; then
    git clone --depth 1 https://github.com/sahaj-b/ghostty-cursor-shaders \
      "$HOME/.config/ghostty/shaders"
  else
    ok "shaders already present"
  fi
  if [[ -f "$HOME/.config/ghostty/config" ]] && ! ask "overwrite existing ~/.config/ghostty/config?" n; then
    warn "keeping existing ghostty config"
  else
    cp "$SCRIPT_DIR/ghostty-config" "$HOME/.config/ghostty/config"
    ok "wrote ~/.config/ghostty/config"
  fi
fi

# -------------------- 7. zsh dotfiles --------------------
step "7/8  ~/.zshrc and ~/.zprofile"
install_dotfile() {
  local src="$1" dst="$2" name="$3"
  if [[ -f "$dst" ]]; then
    local backup="${dst}.backup.$(date +%Y%m%d-%H%M%S)"
    if ask "$name exists. overwrite? (existing backed up to $(basename "$backup"))" n; then
      cp "$dst" "$backup"
    else
      warn "skipping $name"
      return
    fi
  fi
  # substitute /Users/seyeong -> $HOME for portability
  sed "s|/Users/$SOURCE_USER|$HOME|g" "$src" > "$dst"
  ok "installed $name (paths rewritten to \$HOME)"
}
if ask "install ~/.zshrc and ~/.zprofile (auto-rewrite /Users/$SOURCE_USER -> \$HOME)?"; then
  install_dotfile "$SCRIPT_DIR/zshrc"    "$HOME/.zshrc"    ".zshrc"
  install_dotfile "$SCRIPT_DIR/zprofile" "$HOME/.zprofile" ".zprofile"
  warn ".zshrc refers to conda, bun, gcloud, antigravity, opencode — install only what you use, comment out the rest."
fi

# -------------------- 8. Optional: default shell to zsh --------------------
step "8/8  default shell"
if [[ "$SHELL" != */zsh ]]; then
  if ask "change default shell to zsh?"; then
    chsh -s "$(command -v zsh)"
  fi
else
  ok "already zsh"
fi

printf "\n%sAll done.%s Open Ghostty and run:  exec zsh\n" "$GREEN" "$NC"
printf "If agnoster powerline glyphs look wrong, verify Ghostty is using 'JetBrainsMono Nerd Font'.\n"
