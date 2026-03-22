#!/usr/bin/env bash
set -e

# ── Colors & helpers ──────────────────────────────────────────────────────────
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

ok()      { echo -e "  ${GREEN}✓${NC}  $1"; }
arrow()   { echo -e "  ${BLUE}↓${NC}  $1"; }
manual()  { MANUAL_STEPS+=("$1"); }
header()  { echo -e "\n${BOLD}$1${NC}"; }

MANUAL_STEPS=()

echo -e "\n${BOLD}dotfiles bootstrap${NC}"
echo "────────────────────────────────────────"

# ── Homebrew ──────────────────────────────────────────────────────────────────
header "Homebrew"
if ! command -v brew &>/dev/null; then
  arrow "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  ok "Homebrew already installed"
fi

# ── openssl ───────────────────────────────────────────────────────────────────
header "openssl"
if ! brew list openssl &>/dev/null; then
  arrow "Installing openssl..."
  brew install openssl
else
  ok "openssl already installed"
fi

# ── zinit ─────────────────────────────────────────────────────────────────────
header "zinit"
if [ ! -d "$HOME/.zinit" ]; then
  arrow "Installing zinit..."
  bash -c "$(curl --fail --show-error --silent --location \
    https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
else
  ok "zinit already installed"
fi

# ── MesloLGS NF font ──────────────────────────────────────────────────────────
header "MesloLGS NF font"
if ! ls ~/Library/Fonts/MesloLGS* &>/dev/null; then
  arrow "Installing MesloLGS NF..."
  brew install --cask font-meslo-lg-nerd-font
else
  ok "MesloLGS NF already installed"
fi
manual "Set terminal font: iTerm2 → Settings → Profiles → Text → Font → MesloLGS NF"

# ── uv ────────────────────────────────────────────────────────────────────────
header "uv"
if ! command -v uv &>/dev/null; then
  arrow "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
else
  ok "uv already installed"
fi

# ── Rust ──────────────────────────────────────────────────────────────────────
header "Rust"
if ! command -v rustup &>/dev/null; then
  arrow "Installing Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
else
  ok "Rust already installed"
fi

# ── TeX Live ──────────────────────────────────────────────────────────────────
header "TeX Live"
if ! ls /usr/local/texlive/*/bin/universal-darwin &>/dev/null; then
  arrow "Installing MacTeX (this is large ~5GB, may take a while)..."
  brew install --cask mactex-no-gui
else
  ok "TeX Live already installed"
fi

# ── 1Password CLI ─────────────────────────────────────────────────────────────
header "1Password CLI"
if ! command -v op &>/dev/null; then
  arrow "Installing 1Password CLI..."
  brew install --cask 1password-cli
else
  ok "1Password CLI already installed"
fi
if ! security find-generic-password -a "$USER" -s "op-cli-sat" &>/dev/null; then
  manual "Add 1Password service account token to keychain:
     security add-generic-password -a \"\$USER\" -s \"op-cli-sat\" -w \"your-token\""
else
  ok "1Password keychain entry already set"
fi

# ── Google Cloud SDK ──────────────────────────────────────────────────────────
header "Google Cloud SDK"
if ! command -v gcloud &>/dev/null; then
  arrow "Installing Google Cloud SDK..."
  brew install --cask google-cloud-sdk
else
  ok "Google Cloud SDK already installed"
fi
manual "Authenticate gcloud: gcloud auth login && gcloud init"

# ── Sublime Text ──────────────────────────────────────────────────────────────
header "Sublime Text"
if [ ! -d "/Applications/Sublime Text.app" ]; then
  arrow "Installing Sublime Text..."
  brew install --cask sublime-text
else
  ok "Sublime Text already installed"
fi

# ── VS Code ───────────────────────────────────────────────────────────────────
header "VS Code"
if [ ! -d "/Applications/Visual Studio Code.app" ]; then
  arrow "Installing VS Code..."
  brew install --cask visual-studio-code
else
  ok "VS Code already installed"
fi

# ── Docker ────────────────────────────────────────────────────────────────────
header "Docker"
if [ ! -d "/Applications/Docker.app" ]; then
  arrow "Installing Docker Desktop..."
  brew install --cask docker
else
  ok "Docker already installed"
fi

# ── Google Chrome ─────────────────────────────────────────────────────────────
header "Google Chrome"
if [ ! -d "/Applications/Google Chrome.app" ]; then
  arrow "Installing Google Chrome..."
  brew install --cask google-chrome
else
  ok "Google Chrome already installed"
fi

# ── Clone / update dotfiles ───────────────────────────────────────────────────
header "dotfiles"
DOTFILES_DIR="$HOME/dev/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
  arrow "Cloning dotfiles to $DOTFILES_DIR..."
  mkdir -p "$HOME/dev"
  git clone https://github.com/BBischof/dotfiles.git "$DOTFILES_DIR"
else
  arrow "Pulling latest dotfiles..."
  git -C "$DOTFILES_DIR" pull origin main
fi

arrow "Linking dotfiles..."
"$DOTFILES_DIR/install.sh"

# ── Powerlevel10k ─────────────────────────────────────────────────────────────
manual "Configure prompt: open a new shell and run: p10k configure"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}────────────────────────────────────────${NC}"
echo -e "${GREEN}${BOLD}Bootstrap complete!${NC}"

if [ ${#MANUAL_STEPS[@]} -gt 0 ]; then
  echo ""
  echo -e "${YELLOW}${BOLD}Manual steps required:${NC}"
  for i in "${!MANUAL_STEPS[@]}"; do
    echo -e "\n  ${BOLD}$((i+1)).${NC} ${MANUAL_STEPS[$i]}"
  done
fi
echo ""
