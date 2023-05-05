#!/usr/bin/env zsh
: '
scripts/macos/.include/install_exa.sh
'

if type exa &>/dev/null; then
  brew upgrade exa
else
  brew install exa
fi
