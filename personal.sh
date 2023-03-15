# Debugging for profilerate
if [ -w "/dev/stderr" ]; then
  #export _PROFILERATE_STDERR=/dev/stderr
  :
fi

# Debug
echo "Shell: ${PROFILERATE_SHELL}@${SHLVL}"
echo "Profilerate Dir: ${PROFILERATE_DIR}"

# I'm ok with using zsh and i'm ok with using bash. But using dash is not fun
if [ ! "$PROFILERATE_SHELL" = "zsh" ] && [ ! "$PROFILERATE_SHELL" = "bash" ]; then
  if "$PROFILERATE_DIR/bin/bash" --version >/dev/null 2>&1; then
    # Uncomment this after profilerate is no longer in active development
    # echo "Installed and switching to bash"
    # export PATH="$PATH:$PROFILERATE_DIR/bin"
    # PROFILERATE_SHELL="bash" exec $PROFILERATE_DIR/shell.sh
    echo "Bash worked, but ignoring"
  fi
fi

# Used by some applications to store configs. Standardize this (macs are silly)
export XDG_CONFIG_HOME="$HOME/.config"

if [ -n "$(command -v bindkey)" ]
then
  # zsh key bindings
  bindkey "\e[1;3D" backward-word
  bindkey "\e[1;3C" forward-word
elif [ -n "$(command -v bind)" ]
then
  # bash key bindings
  bind '"\e[1;3D" backward-word'
  bind '"\e[1;3C" forward-word'
fi

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
  export LESS="-iXFR"
  export PAGER="less -iXFR"
  alias less="less -iXFR"
fi

# use bat if it's available
if [ -n "$(command -v bat)" ]
then
  export BAT_THEME="Dracula"
  alias cat="bat"
fi

# use erdtree instead of du
if [ -n "$(command -v et)" ]
then
  alias du="et -s size-rev"
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

# Reset kitty term (otherwise ssh gets angry)
export TERM="xterm"

if [ -n "$KUBERNETES_SERVICE_HOST" ]
then
  export PROFILERATE_LOGO="󱃾 "
elif [ -n "$SSH_CLIENT"  ]
then
  export PROFILERATE_LOGO="󰣀 "
fi

### Shell specific configurations ###
if [ "$PROFILERATE_SHELL" = "zsh" ]; then
  autoload -U colors && colors 2>/dev/null
  setopt PROMPT_SUBST
  if [ "${PROFILERATE_LOGO:-}" = " " ]
  then
    LOGO_PS1="$PROFILERATE_LOGO"
  else
    LOGO_PS1="%{$fg[red]%}${PROFILERATE_LOGO:-"󱚟 "}"
  fi
  PROMPT="${LOGO_PS1}%{$fg[cyan]%}%n%{$reset_color%}@%{$fg[yellow]%}%M:%{$fg[green]%}%~"
  if command -v "git_prompt_info" >/dev/null
  then
    PROMPT="$PROMPT\$(git_prompt_info)"
  fi
  PROMPT="$PROMPT%{$reset_color%}%(!.#.$) "
  export PS1=$PROMPT
elif [ "$PROFILERATE_SHELL" = "bash" ]; then
  if [ "${PROFILERATE_LOGO:-}" = " " ]
  then
    LOGO_PS1="\[\e[0;0m\]$PROFILERATE_LOGO"
  else
    LOGO_PS1="\[\e[0;91m\]${PROFILERATE_LOGO:-"󱚟 "}"
  fi
  export PS1="${LOGO_PS1}\[\e[0;96m\]\u\[\e[0;97m\]@\[\e[0;93m\]\H\[\e[0;97m\]:\[\e[0;92m\]\w\[\e[0m\]$ "
else
  export PS1='${PROFILERATE_LOGO:-}[96m${USER:=$(whoami 2>/dev/null || echo who-am-i)}[97m@[93m${HOSTNAME:=$(hostname)}[97m:[92m$PWD[0m\$ '
fi

