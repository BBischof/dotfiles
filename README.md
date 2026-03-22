# dotfiles

Personal shell configuration. Everything lives in a single `.zshrc`.

## Fresh install

Run this on a new machine:

```sh
curl -fsSL https://raw.githubusercontent.com/BBischof/dotfiles/main/bootstrap.sh | bash
```

This will:
1. Install [Homebrew](https://brew.sh) (if missing)
2. Install [zinit](https://github.com/zdharma-continuum/zinit) plugin manager
3. Install [MesloLGS NF](https://github.com/romkatv/powerlevel10k#fonts) font (required for prompt)
4. Install [uv](https://github.com/astral-sh/uv) Python package manager
5. Clone this repo to `~/dev/dotfiles`
6. Symlink `~/.zshrc` → `~/dev/dotfiles/.zshrc`

### After bootstrap — manual steps

**1. Set your terminal font**
- iTerm2: Settings → Profiles → Text → Font → **MesloLGS NF**

**2. Add your 1Password CLI service account token**
```sh
security add-generic-password -a "$USER" -s "op-cli-sat" -w "your-token-here"
```

**3. Configure the prompt**
Open a new shell — Powerlevel10k will walk you through setup automatically, or run:
```sh
p10k configure
```

### Optional tools
```sh
brew install --cask sublime-text    # default EDITOR
brew install --cask google-cloud-sdk
brew install rust
brew install --cask mactex          # TeX Live
```

---

## What's included

- **Prompt**: [Powerlevel10k](https://github.com/romkatv/powerlevel10k) via zinit
- **Plugins**: zsh-autosuggestions, fast-syntax-highlighting, zsh-completions
- **Tools configured**: Homebrew, uv, Rust/Cargo, TeX Live, Google Cloud SDK, 1Password CLI
- **Aliases**: navigation, git, docker, dev tools, OpenMemory project shortcuts

## Ongoing workflow

Since `~/.zshrc` is symlinked to the repo, changes take effect immediately. To save changes:

```sh
cd ~/dev/dotfiles
git add .zshrc
git commit -m "your message"
git push
```

## Migrating from Oh My Zsh

```sh
uninstall_oh_my_zsh
curl -fsSL https://raw.githubusercontent.com/BBischof/dotfiles/main/bootstrap.sh | bash
```
