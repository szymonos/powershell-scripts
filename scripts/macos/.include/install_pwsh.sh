#!/usr/bin/env zsh
: '
scripts/macos/.include/install_pwsh.sh
'

if type oh-my-posh &>/dev/null; then
  brew upgrade powershell
else
  brew tap homebrew/cask-versions
  brew install --cask powershell
fi
