# dotfiles

Personal shell configuration. Everything lives in a single `.zshrc`.

## Fresh install

Run this on a new machine:

```sh
curl -fsSL https://raw.githubusercontent.com/BBischof/dotfiles/main/bootstrap.sh | bash
```

The script checks for each dependency, installs anything missing, and prints a clear list of manual steps at the end. Safe to re-run — everything is idempotent.

### What gets installed automatically

| Tool | Purpose |
|------|---------|
| [Homebrew](https://brew.sh) | Package manager |
| openssl | TLS/SSL |
| [zinit](https://github.com/zdharma-continuum/zinit) | Zsh plugin manager |
| [MesloLGS NF](https://github.com/romkatv/powerlevel10k#fonts) | Font for Powerlevel10k prompt |
| [uv](https://github.com/astral-sh/uv) | Python package manager |
| [Rust](https://rustup.rs) | via rustup |
| [MacTeX](https://www.tug.org/mactex/) | TeX Live (~5GB) |
| [1Password CLI](https://developer.1password.com/docs/cli/) | `op` CLI |
| [Google Cloud SDK](https://cloud.google.com/sdk) | `gcloud` |
| [Sublime Text](https://www.sublimetext.com) | Default editor |
| [VS Code](https://code.visualstudio.com) | |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | |
| [Google Chrome](https://www.google.com/chrome/) | |

### Manual steps (printed at the end of bootstrap)

These can't be automated — the script will remind you:

1. **Set terminal font** — iTerm2 → Settings → Profiles → Text → Font → **MesloLGS NF**
2. **Add 1Password service account token** to keychain:
   ```sh
   security add-generic-password -a "$USER" -s "op-cli-sat" -w "your-token-here"
   ```
3. **Authenticate gcloud**:
   ```sh
   gcloud auth login && gcloud init
   ```
4. **Configure prompt** — open a new shell and run `p10k configure`

---

## What's in `.zshrc`

- **Prompt**: [Powerlevel10k](https://github.com/romkatv/powerlevel10k) via zinit
- **Plugins**: zsh-autosuggestions, fast-syntax-highlighting, zsh-completions
- **Tools**: Homebrew, uv, Rust/Cargo, TeX Live, Google Cloud SDK, 1Password CLI
- **Aliases**: navigation, git, docker, dev tools, OpenMemory project shortcuts

## Ongoing workflow

Since `~/.zshrc` is symlinked to this repo, edits take effect immediately. To save changes:

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
