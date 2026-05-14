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

# Git hooks
GIT_HOOKS_SRC="$DOTFILES_DIR/git-hooks"
GIT_HOOKS_DEST="$HOME/.config/git/hooks"
mkdir -p "$GIT_HOOKS_DEST"
for hook in "$GIT_HOOKS_SRC"/*; do
  hook_name="$(basename "$hook")"
  dest_hook="$GIT_HOOKS_DEST/$hook_name"
  if [ -L "$dest_hook" ]; then
    echo "already symlinked: $dest_hook"
  else
    ln -sf "$hook" "$dest_hook"
    chmod +x "$dest_hook"
    echo "linked: $dest_hook → $hook"
  fi
done
git config --global core.hooksPath "$GIT_HOOKS_DEST"
echo "git hooks installed → $GIT_HOOKS_DEST"

# load_secrets.sh
mkdir -p "$HOME/local_secrets"
SECRETS_LOADER_SRC="$DOTFILES_DIR/load_secrets.sh"
SECRETS_LOADER_DEST="$HOME/local_secrets/load_secrets.sh"
if [ -L "$SECRETS_LOADER_DEST" ]; then
  echo "already symlinked: $SECRETS_LOADER_DEST"
elif [ -f "$SECRETS_LOADER_DEST" ]; then
  echo "backing up existing $SECRETS_LOADER_DEST → $SECRETS_LOADER_DEST.bak"
  mv "$SECRETS_LOADER_DEST" "$SECRETS_LOADER_DEST.bak"
  ln -s "$SECRETS_LOADER_SRC" "$SECRETS_LOADER_DEST"
  echo "linked: $SECRETS_LOADER_DEST → $SECRETS_LOADER_SRC"
else
  ln -s "$SECRETS_LOADER_SRC" "$SECRETS_LOADER_DEST"
  echo "linked: $SECRETS_LOADER_DEST → $SECRETS_LOADER_SRC"
fi

echo "done. open a new shell or run: source ~/.zshrc"
