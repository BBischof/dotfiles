# ── Powerlevel10k instant prompt ──────────────────────────────────────────────
# Must stay at the top of ~/.zshrc
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Homebrew ──────────────────────────────────────────────────────────────────
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="${HOMEBREW_PREFIX}/opt/openssl/bin:$PATH"

# ── 1Password CLI ─────────────────────────────────────────────────────────────
export OP_SERVICE_ACCOUNT_TOKEN=$(security find-generic-password -a "$USER" -s "op-cli-sat" -w 2>/dev/null)

# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH="$HOME/.cargo/bin:$PATH"
for _tex_dir in /usr/local/texlive/*/bin/universal-darwin; do
  [[ -d "$_tex_dir" ]] && export PATH="$_tex_dir:$PATH" && break
done
unset _tex_dir
export PATH="$PATH:$HOME/.local/bin"

# ── uv ────────────────────────────────────────────────────────────────────────
. "$HOME/.local/bin/env"

# ── Editor & Colors ───────────────────────────────────────────────────────────
export EDITOR='subl -w'
LS_COLORS=$LS_COLORS:'di=0;35:' ; export LS_COLORS

# ── zinit + plugins ───────────────────────────────────────────────────────────
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-completions

# ── Powerlevel10k config ───────────────────────────────────────────────────────
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ── Google Cloud SDK ──────────────────────────────────────────────────────────
for _gcloud_dir in "$HOME/google-cloud-sdk" "$HOME/dev_other/google-cloud-sdk"; do
  [[ -f "$_gcloud_dir/path.zsh.inc" ]] && source "$_gcloud_dir/path.zsh.inc"
  [[ -f "$_gcloud_dir/completion.zsh.inc" ]] && source "$_gcloud_dir/completion.zsh.inc"
done
unset _gcloud_dir

# ── Local secrets ─────────────────────────────────────────────────────────────
[[ -f "$HOME/local_secrets/load_secrets.sh" ]] && source "$HOME/local_secrets/load_secrets.sh"

# ── Aliases: navigation ───────────────────────────────────────────────────────
alias ll='ls -Gflah'
alias ..='cd ..'
alias ...='cd ../..'

# ── Aliases: tools ────────────────────────────────────────────────────────────
alias dco='docker compose'
alias chrome="open -a 'Google Chrome'"
alias code='open -a "Visual Studio Code"'
alias subl='/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl'
alias catdupheaders="awk 'FNR>1 || NR==1'"

# ── Aliases: git ──────────────────────────────────────────────────────────────
alias main='git checkout main && git pull origin main'
alias newb='git checkout -b'
alias gitac='git add . && git commit'
alias gck='git checkout'

# ── Aliases: dev ──────────────────────────────────────────────────────────────
alias rufflongok="pre-commit run --all-files --hook-stage manual ruff | grep -v \"E501\""

# ── Aliases: OpenMemory ───────────────────────────────────────────────────────
alias pr='python -m core.parse_resources --rebuild'
alias pt='pytest --cov=core --cov=app --cov-report=term-missing:skip-covered'
alias jt='npm run test:coverage'
alias et='invoke e2e'
