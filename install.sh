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

echo "done. open a new shell or run: source ~/.zshrc"
