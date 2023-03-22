if [ -w "/dev/stderr" ]; then
  # Uncomment to turn on noisy debugging for profilerate
  #export _PROFILERATE_STDERR=/dev/stderr
  :
fi

# Debugging for profilerate
# I Keep this on, but you can delete
echo "Shell: ${PROFILERATE_SHELL}@${SHLVL}"
echo "Profilerate Dir: ${PROFILERATE_DIR}"

# Ignore files set to include README.md
export _PROFILERATE_IGNORE_PATHS=".git/ .github/ .gitignore README.md"

# I'm ok with using zsh and i'm ok with using bash. But using dash is not fun
if [ ! "$PROFILERATE_SHELL" = "zsh" ] && [ ! "$PROFILERATE_SHELL" = "bash" ]; then
  if "$PROFILERATE_DIR/bin/bash" --version >/dev/null 2>&1; then
    # Uncomment this after profilerate is no longer in active development
    # echo "Installed and switching to bash"
    # export PATH="$PATH:$PROFILERATE_DIR/bin"
    # PROFILERATE_SHELL="bash" exec $PROFILERATE_DIR/shell.sh
    :
  fi
fi

# Helper function to convert a hex in the format FF (no 0x or #) to decimal
convert_hex () {
  printf "%d\n" "0x${1}"
}

# Set kitty tab color. Eg set_tab_color "eeeeee" "999999"
set_tab_color () {
  printf "\eP@kitty-cmd{\"cmd\":\"set-tab-color\",\"version\":[0,14,2],\"no_response\": true,\"payload\":{\"colors\": { \"active_bg\": \"$(convert_hex $1)\", \"inactive_bg\": \"$(convert_hex $2)\" }}}\e\\"
}

reset_terminal="printf '\\x1b]11;${PROFILERATE_BACKGROUND:-#000}\\x1b\\\\'; set_tab_color ${PROFILERATE_TAB_ACTIVE:-eeeeee} ${PROFILERATE_TAB_INACTIVE:-999999}"
# profilerate aliases
dr () {
  # Set background color to #200
  printf '\x1b]11;#200\x1b\\'
  # Set tab colors
  set_tab_color "FFAAAA" "CC7777"
  # Run the normal command, but pass the env variables so that when we reset, we use the right values (for the case of jump hosts)
  PROFILERATE_PRECOMMAND='export PROFILERATE_BACKGROUND="#200" PROFILERATE_TAB_ACTIVE="FFAAAA" PROFILERATE_TAB_INACTIVE="CC7777" PROFILERATE_LOGO=" "' profilerate_docker_run "$@"
  # reset background color
  eval "$reset_terminal"
}
de () {
  printf '\x1b]11;#200\x1b\\'
  set_tab_color "FFAAAA" "CC7777"
  PROFILERATE_PRECOMMAND='export PROFILERATE_BACKGROUND="#200" PROFILERATE_TAB_ACTIVE="FFAAAA" PROFILERATE_TAB_INACTIVE="CC7777" PROFILERATE_LOGO=" "' profilerate_docker_exec "$@"
  eval "$reset_terminal"
}
ke () {
  printf '\x1b]11;#020\x1b\\'
  set_tab_color "AAFFAA" "77CC77"
  PROFILERATE_PRECOMMAND='export PROFILERATE_BACKGROUND="#020" PROFILERATE_TAB_ACTIVE="AAFFAA" PROFILERATE_TAB_INACTIVE="77CC77" PROFILERATE_LOGO="󱃾 "' profilerate_kubectl_exec "$@"
  eval "$reset_terminal"
}
s () {
  printf '\x1b]11;#002\x1b\\'
  set_tab_color "AAAAFF" "7777CC"
  PROFILERATE_PRECOMMAND='export PROFILERATE_BACKGROUND="#002" PROFILERATE_TAB_ACTIVE="AAAAFF" PROFILERATE_TAB_INACTIVE="7777CC" PROFILERATE_LOGO="󰣀 "' profilerate_ssh "$@"
  eval "$reset_terminal"
}

# kubernetes aliases
alias k="kubectl"

# TODO: research implications of doing this. You should probably comment this out
# Used by some applications to store configs. Standardize this
export XDG_CONFIG_HOME="$HOME/.config"

# Try for some cross shell keybindings
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

# Aliases for vim related things
if [ -n "$(command -v nvim)" ]
then
  # Always use nvim if available
  alias vim=nvim
  alias vi=nvim
  export EDITOR="nvim"
elif [ -n "$(command -v vim)" ]
then
  # Otherwise always use vim
  alias vi=vim
  export EDITOR="vim"
elif [ -n "$(command -v vi)" ]
then
  # Otherwise be sad
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

# This var is set in ~/.zshrc on my local machine
if [ -n "$I_AM_LOCAL" ]
then
  # On local, set the logo to an apple
  export PROFILERATE_LOGO=" "
elif [ -z "$PROFILERATE_LOGO" ]
then
  # If no logo was set, use something...
  export PROFILERATE_LOGO="󱚟 "
fi

### Shell specific configurations ###
if [ "$PROFILERATE_SHELL" = "zsh" ]; then
  autoload -U colors 2>/dev/null && colors 2>/dev/null
  setopt PROMPT_SUBST

  # For local, make the logo white, otherwise make it stand out
  if [ -n "$I_AM_LOCAL" ]
  then
    LOGO_PS1="$PROFILERATE_LOGO"
  else
    LOGO_PS1="%{$fg[red]%}${PROFILERATE_LOGO}"
  fi

  # Logo + Logged in user
  PROMPT="${LOGO_PS1}%{$fg[cyan]%}%n"

  if [ -z "$I_AM_LOCAL" ]
  then
    # For non-local, add the host in yellow
    PROMPT="$PROMPT%{$reset_color%}@%{$fg[yellow]%}%M"
  fi

  # path
  PROMPT="$PROMPT%{$reset_color%}:%{$fg[green]%}%~"

  # Add git prompt, if available
  if command -v "git_prompt_info" >/dev/null
  then
    ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[magenta]%}git:("
    ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"
    PROMPT="$PROMPT%{$fg[magenta]%}\$(git_prompt_info)"
  fi

  # and the final prompt
  PROMPT="$PROMPT%{$reset_color%}%(!.#.$) "
  PIPENV_PROMPT='$(test -n "$PYENV_DIR" && echo "($(basename "$PYENV_DIR")) ")'
  export PS1="$PIPENV_PROMPT$PROMPT"

  # kubernetes auto complete in bash
  if [ -n "$(command -v kubectl)" ]
  then
    source <(kubectl completion zsh)
    complete -F __start_kubectl k
  fi
elif [ "$PROFILERATE_SHELL" = "bash" ]; then
  # Autocomplete for bash
  [ -f /opt/homebrew/etc/bash_completion ] && . /opt/homebrew/etc/bash_completion
  [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

  # kubernetes auto complete in bash
  if [ -n "$(command -v kubectl)" ]
  then
    source <(kubectl completion bash)
    complete -F __start_kubectl k
  fi

  if [ -n "$I_AM_LOCAL" ]
  then
    LOGO_PS1="\[\e[0;0m\]${PROFILERATE_LOGO}"
  else
    LOGO_PS1="\[\e[0;91m\]${PROFILERATE_LOGO}"
  fi
  export PS1="${LOGO_PS1}\[\e[0;96m\]\u\[\e[0;97m\]@\[\e[0;93m\]\H\[\e[0;97m\]:\[\e[0;92m\]\w\[\e[0m\]$ "
else
  if [ -n "$I_AM_LOCAL" ]
  then
    LOGO_PS1="${PROFILERATE_LOGO}"
  else
    LOGO_PS1="[91m${PROFILERATE_LOGO}"
  fi
  export PS1='$LOGO_PS1[96m${USER:=$(whoami 2>/dev/null || echo who-am-i)}[97m@[93m${HOSTNAME:=$(hostname)}[97m:[92m$PWD[0m<󰚌>$ '
fi

