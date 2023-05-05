#!/usr/bin/env bash
: '
scripts/linux/update_powershell.sh
'
if [ $EUID -eq 0 ]; then
  printf '\e[31;1mDo not run the script as root.\e[0m\n'
  exit 1
fi

# *Upgrade oh-my-posh
sudo scripts/linux/.include/install_omp.sh >/dev/null

# *Upgrade PowerShell
sudo scripts/linux/.include/install_pwsh.sh >/dev/null

# *Update modules
scripts/linux/.include/update_psresources.ps1
sudo scripts/linux/.include/update_psresources.ps1
