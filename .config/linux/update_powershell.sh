#!/usr/bin/env bash
: '
.config/linux/update_powershell.sh
'
if [ $EUID -eq 0 ]; then
  printf '\e[31;1mDo not run the script as root.\e[0m\n'
  exit 1
fi

# *Upgrade oh-my-posh
sudo .config/linux/scripts/install_omp.sh

# *Upgrade PowerShell
sudo .config/linux/scripts/install_pwsh.sh

# *Update modules
.config/linux/scripts/update_psresources.ps1
sudo .config/linux/scripts/update_psresources.ps1
