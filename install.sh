#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DOTFILES=(
  .zshrc
)

for file in "${DOTFILES[@]}"; do
  src="$DOTFILES_DIR/$file"
  dest="$HOME/$file"

  if [ -L "$dest" ]; then
    echo "already symlinked: $dest"
  elif [ -f "$dest" ]; then
    echo "backing up existing $dest → $dest.bak"
    mv "$dest" "$dest.bak"
    ln -s "$src" "$dest"
    echo "linked: $dest → $src"
  else
    ln -s "$src" "$dest"
    echo "linked: $dest → $src"
  fi
done

# Ghostty config
mkdir -p "$HOME/.config/ghostty"
GHOSTTY_SRC="$DOTFILES_DIR/ghostty"
GHOSTTY_DEST="$HOME/.config/ghostty/config"
if [ -L "$GHOSTTY_DEST" ]; then
  echo "already symlinked: $GHOSTTY_DEST"
elif [ -f "$GHOSTTY_DEST" ]; then
  echo "backing up existing $GHOSTTY_DEST → $GHOSTTY_DEST.bak"
  mv "$GHOSTTY_DEST" "$GHOSTTY_DEST.bak"
  ln -s "$GHOSTTY_SRC" "$GHOSTTY_DEST"
  echo "linked: $GHOSTTY_DEST → $GHOSTTY_SRC"
else
  ln -s "$GHOSTTY_SRC" "$GHOSTTY_DEST"
  echo "linked: $GHOSTTY_DEST → $GHOSTTY_SRC"
fi

echo "done. open a new shell or run: source ~/.zshrc"
