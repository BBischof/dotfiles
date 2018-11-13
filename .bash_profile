
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1="\h:\W☕ \$(parse_git_branch)\$ "

LS_COLORS=$LS_COLORS:'di=0;35:' ; export LS_COLORS
alias ll='ls -Gflah'
alias ..="cd .."
alias ...="cd ../.."
alias dco="docker-compose"
alias chrome="Google\ Chrome"
alias catdupheaders="awk 'FNR>1 || NR==1'"

export PATH=/bin:/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:$PATH
export EDITOR='subl -w'

eval "$(direnv hook bash)"

if [ -f ~/.bashrc ]; then
source ~/.bashrc
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
