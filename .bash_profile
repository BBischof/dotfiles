export PATH=/bin:/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:$PATH
export PATH="$HOME/.pyenv/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export EDITOR='subl -w'

if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)"; fi

alias ll='ls -Gflah'
alias ..='cd ..'
alias ...='cd ../..'
