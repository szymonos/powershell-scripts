#!/usr/bin/env zsh
: '
.config/macos/scripts/install_exa.sh
'

if type exa &>/dev/null; then
  brew upgrade exa
else
  brew install exa
fi
