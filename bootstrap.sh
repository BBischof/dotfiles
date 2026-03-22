#!/usr/bin/env bash
set -e

echo "==> Starting dotfiles bootstrap..."

# ── Homebrew ──────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "==> Homebrew already installed"
fi

# ── zinit ─────────────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.zinit" ]; then
  echo "==> Installing zinit..."
  bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
else
  echo "==> zinit already installed"
fi

# ── MesloLGS NF font ──────────────────────────────────────────────────────────
if ! fc-list 2>/dev/null | grep -q "MesloLGS" && \
   ! ls ~/Library/Fonts/MesloLGS* &>/dev/null; then
  echo "==> Installing MesloLGS NF font..."
  brew install --cask font-meslo-lg-nerd-font
else
  echo "==> MesloLGS NF already installed"
fi

# ── uv ────────────────────────────────────────────────────────────────────────
if ! command -v uv &>/dev/null; then
  echo "==> Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
else
  echo "==> uv already installed"
fi

# ── Clone dotfiles ────────────────────────────────────────────────────────────
DOTFILES_DIR="$HOME/dev/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "==> Cloning dotfiles to $DOTFILES_DIR..."
  mkdir -p "$HOME/dev"
  git clone https://github.com/BBischof/dotfiles.git "$DOTFILES_DIR"
else
  echo "==> Dotfiles already present, pulling latest..."
  git -C "$DOTFILES_DIR" pull origin main
fi

# ── Symlink dotfiles ──────────────────────────────────────────────────────────
echo "==> Linking dotfiles..."
"$DOTFILES_DIR/install.sh"

echo ""
echo "✓ Bootstrap complete!"
echo ""
echo "Manual steps remaining:"
echo "  1. Set iTerm2 font: Settings → Profiles → Text → Font → MesloLGS NF"
echo "  2. Add 1Password CLI token to keychain:"
echo "     security add-generic-password -a \"\$USER\" -s \"op-cli-sat\" -w \"your-token\""
echo "  3. Open a new shell — p10k will guide you through prompt setup"
echo "     (or run: p10k configure)"
