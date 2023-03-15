# profilerate aliases
alias de="profilerate_docker_exec -e 'PROFILERATE_LOGO= '"
alias dr="profilerate_docker_run -e 'PROFILERATE_LOGO= '"
alias ke="profilerate_kubectl_exec"
alias s="profilerate_ssh"

# Aliases for nvim
if [ -n "$(command -v nvim)" ]
then
  alias vim=nvim
  alias vi=nvim
  export EDITOR="nvim"
elif [ -n "$(command -v vim)" ]
then
  alias vi=vim
  export EDITOR="vim"
elif [ -n "$(command -v vi)" ]
then
  export EDITOR="vi"
fi

# Set Pager to less with case insensitive and some other features
if [ -n "$(command -v less)" ]
then
  export LESS="-iXF"
  export PAGER="less -iXF"
  alias less="less -iXF"
fi

# use bat if it's available
if [ -n "$(command -v bat)" ]
then
  export BAT_THEME="Dracula"
  alias cat="bat"
fi

# use dust instead of du
if [ -n "$(command -v dust)" ]
then
  alias du="dust"
fi

# use delta instead of diff
if [ -n "$(command -v delta)" ]
then
  alias diff="delta"
fi

# color ls
if ls --color=always >/dev/null 2>&1
then
  alias ls="ls -last --color=always"
else
  alias ls="ls -lastG"
fi

# Reset kitty term
export TERM=xterm

if [ -n "$KUBERNETES_SERVICE_HOST" ]
then
  export PROFILERATE_LOGO="󱃾 "
elif [ -n "$SSH_CLIENT"  ]
then
  export PROFILERATE_LOGO="󰣀 "
fi

### Shell specific configurations ###
if [ "$PROFILERATE_SHELL" = "zsh" ]; then
  autoload -U colors && colors
  export PS1="${PROFILERATE_LOGO:-}%{$fg[cyan]%}%n%{$reset_color%}@%{$fg[yellow]%}%M:%{$fg[green]%}%/%{$reset_color%}%(!.#.$) "
elif [ "$PROFILERATE_SHELL" = "bash" ]; then
  export PS1="${PROFILERATE_LOGO:-}\[\e[0;96m\]\u\[\e[0;97m\]@\[\e[0;93m\]\h\[\e[0;93m\]:\[\e[0;92m\]\w\[\e[0m\]\[\e[0m\]$\[\e[0m\] \[\e[0m\]"
else
  export PS1='${PROFILERATE_LOGO:-}${USER:=$(whoami)}@${HOSTNAME:=$(hostname)}:$PWD\$ '
fi

# Debug
echo "Shell: ${PROFILERATE_SHELL}"
echo "Profilerate Dir: ${PROFILERATE_DIR}"
