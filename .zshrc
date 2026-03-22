# ── 1Password CLI ─────────────────────────────────────────────────────────────
export OP_SERVICE_ACCOUNT_TOKEN=$(security find-generic-password -a "$USER" -s "op-cli-sat" -w 2>/dev/null)

# ── Homebrew ──────────────────────────────────────────────────────────────────
eval "$(/opt/homebrew/bin/brew shellenv)"

# ── Python / pyenv ────────────────────────────────────────────────────────────
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# ── Rust / Cargo ──────────────────────────────────────────────────────────────
export PATH="$HOME/.cargo/bin:$PATH"

# ── uv ────────────────────────────────────────────────────────────────────────
. "$HOME/.local/bin/env"

# ── TeX Live ──────────────────────────────────────────────────────────────────
export PATH="/usr/local/texlive/2022/bin/universal-darwin:$PATH"

# ── Google Cloud SDK ──────────────────────────────────────────────────────────
if [ -f '/Users/bryanbischof/dev_other/google-cloud-sdk/path.zsh.inc' ]; then
  . '/Users/bryanbischof/dev_other/google-cloud-sdk/path.zsh.inc'
fi
if [ -f '/Users/bryanbischof/dev_other/google-cloud-sdk/completion.zsh.inc' ]; then
  . '/Users/bryanbischof/dev_other/google-cloud-sdk/completion.zsh.inc'
fi

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git)
source $ZSH/oh-my-zsh.sh

# ── Prompt ────────────────────────────────────────────────────────────────────
PROMPT='%{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

# ── Editor ────────────────────────────────────────────────────────────────────
export EDITOR='subl -w'

# ── Colors ────────────────────────────────────────────────────────────────────
LS_COLORS=$LS_COLORS:'di=0;35:' ; export LS_COLORS

# ── Aliases ───────────────────────────────────────────────────────────────────
alias ll='ls -Gflah'
alias ..='cd ..'
alias ...='cd ../..'
alias dco='docker-compose'
alias code='open -a "Visual Studio Code"'
alias subl='/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl'
alias main='git checkout main && git pull origin main'

# ── Project: OpenMemory ───────────────────────────────────────────────────────
alias pr='python -m core.parse_resources --rebuild'
alias pt='pytest --cov=core --cov=app --cov-report=term-missing:skip-covered'
alias jt='npm run test:coverage'
alias et='invoke e2e'
