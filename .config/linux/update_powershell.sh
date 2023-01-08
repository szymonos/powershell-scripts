#!/bin/bash
: '
.config/linux/update_powershell.sh
'
if [[ $EUID -eq 0 ]]; then
  echo -e '\e[91mDo not run the script as root!\e[0m'
  exit 1
fi

# *Upgrade oh-my-posh
sudo .config/linux/scripts/install_omp.sh

# *Upgrade PowerShell
sudo .config/linux/scripts/install_pwsh.sh

# *Update modules
.include/manage_psmodules.ps1
sudo .include/manage_psmodules.ps1
