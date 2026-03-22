# dotfiles

Personal shell configuration. Everything lives in a single `.zshrc`.

## What's included

- **Prompt**: [Powerlevel10k](https://github.com/romkatv/powerlevel10k) via [zinit](https://github.com/zdharma-continuum/zinit)
- **Plugins**: zsh-autosuggestions, fast-syntax-highlighting, zsh-completions
- **Tools**: Homebrew, uv, Rust/Cargo, TeX Live, Google Cloud SDK, 1Password CLI
- **Aliases**: navigation, git, docker, dev tools, OpenMemory project shortcuts

## Fresh install

### 1. Install Homebrew
```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install zinit
```sh
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
```

### 3. Install MesloLGS NF font (required for Powerlevel10k)
```sh
brew install --cask font-meslo-lg-nerd-font
```

Then set your terminal font to **MesloLGS NF**:
- **iTerm2**: Settings → Profiles → Text → Font

### 4. Install uv
```sh
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 5. Link dotfiles
```sh
git clone git@github.com:BBischof/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
./install.sh
```

This symlinks `~/.zshrc` → `~/dev/dotfiles/.zshrc`. Any edits to `~/.zshrc` are edits to the repo — just commit and push. Existing files are backed up as `.bak` before being replaced.

### 6. Set up Powerlevel10k
Open a new shell — p10k will prompt you to configure it, or run:
```sh
p10k configure
```

### 7. Optional tools
```sh
brew install --cask sublime-text   # EDITOR=subl
brew install --cask google-cloud-sdk
brew install rust
brew install --cask mactex         # TeX Live
```

### 8. 1Password CLI
The config reads a service account token from the macOS keychain:
```sh
security add-generic-password -a "$USER" -s "op-cli-sat" -w "your-token-here"
```

### 9. Local secrets (optional)
If you use a local secrets file, create it at:
```sh
~/local_secrets/load_secrets.sh
```
It will be sourced automatically on shell start.

## Migrating from Oh My Zsh

```sh
# Remove Oh My Zsh
uninstall_oh_my_zsh

# Then follow the fresh install steps above
```
