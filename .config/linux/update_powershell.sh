#!/bin/bash
: '
.config/linux/update_powershell.sh
'
if [[ $EUID -eq 0 ]]; then
  echo -e '\e[91mDo not run the script with sudo!\e[0m'
  exit 1
fi

# *Upgrade oh-my-posh
sudo .config/linux/scripts/install_omp.sh

# *Upgrade PowerShell
sudo .config/linux/scripts/install_pwsh.sh

# *Update modules
pwsh -nop .include/manage_psmodules.ps1
sudo pwsh -nop .include/manage_psmodules.ps1
