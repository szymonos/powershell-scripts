#!/usr/bin/env zsh
: '
.config/macos/scripts/install_omp.sh
'

if type oh-my-posh &>/dev/null; then
  brew upgrade oh-my-posh
else
  brew install oh-my-posh
fi
