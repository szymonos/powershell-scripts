#!/usr/bin/env bash
: '
.config/macos/scripts/install_brew.sh
'
if type brew &>/dev/null; then
  brew update && brew upgrade
else
  export HOMEBREW_INSTALL_FROM_API=1
  while ! [[ -f /opt/homebrew/bin/brew ]]; do
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  done
fi
