
#
# ~/.zshrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
export PROMPT="$ "

# starship
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# nvm
export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh" # This loads nvm
fi
if [ -d "$NVM_DIR" ] && [ -s "$NVM_DIR/zsh_completion" ]; then
  . "$NVM_DIR/zsh_completion" # This loads nvm zsh_completion
fi

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT/bin" ]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  if command -v pyenv &>/dev/null; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
  fi
fi

# rustup
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

# scala
if [ -d "$HOME/.local/share/coursier/bin" ]; then
  export PATH="$PATH:$HOME/.local/share/coursier/bin"
fi

# go
if command -v go &>/dev/null; then
  GOPATH=$(go env GOPATH)
  if [ -n "$GOPATH" ] && [ -d "$GOPATH/bin" ]; then
    export PATH="$PATH:$GOPATH/bin"
  fi
fi

# global
if [ -d "$HOME/.global/bin" ]; then
  export PATH="$PATH:$HOME/.global/bin"
fi

# php-composer
if [ -d "$HOME/.config/composer/vendor/bin" ]; then
  export PHP_CS_FIXER_IGNORE_ENV=1
  export PATH="$PATH:$HOME/.config/composer/vendor/bin"
fi

# wsl
if [ -n "$WSL_DISTRO_NAME" ]; then
  source $HOME/.win/wsl/.zshrc
else
  # only cli using option for me
  # i use kmscon when i work on CLI environment.
  if [ "$COLORTERM" = "kmscon" ]; then
    uim-fep
  fi
fi

# aliases
if command -v wl-copy &>/dev/null; then
  alias wl="wl-copy"
fi
if command -v nvim &>/dev/null; then
  alias n="nvim ./"
fi
if command -v lazygit &>/dev/null; then
  alias lg="lazygit"
fi
if command -v kitty &>/dev/null; then
  alias icat='kitty +kitten icat'
fi

# read secret .zshrc
if [ -f $HOME/.secret/.zshrc ]; then
  source ~/.secret/.zshrc
fi

export EDITOR=nvim

# if there is a .dynamic_zshrc file, source it
if [ -f "$HOME/.dynamic_zshrc" ]; then
  source "$HOME/.dynamic_zshrc"
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/tk/.sdkman"
[[ -s "/Users/tk/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/tk/.sdkman/bin/sdkman-init.sh"

. "$HOME/.local/bin/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/tk/.lmstudio/bin"
# End of LM Studio CLI section


alias curlc='curl -s -o /dev/null -w "%{http_code}\n"'
