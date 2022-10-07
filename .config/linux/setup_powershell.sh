#!/bin/bash
: '
.config/linux/setup_powershell.sh     #* install basic oh-my-posh profile
.config/linux/setup_powershell.sh pl  #* install powerline oh-my-posh profile
'
if [[ $EUID -eq 0 ]]; then
  echo -e '\e[91mDo not run the script with sudo!\e[0m'
  exit 1
fi

# *Install oh-my-posh
sudo .config/linux/scripts/install_omp.sh
# copy omp theme
if [ "$1" = 'pl' ]; then
  sudo \cp -f .config/linux/config/theme-pl.omp.json /etc/profile.d/theme.omp.json
else
  sudo \cp -f .config/linux/config/theme.omp.json /etc/profile.d/theme.omp.json
fi

# *Install PowerShell
sudo .config/linux/scripts/install_pwsh.sh
# copy profile and aliases
sudo \cp -f .config/linux/config/profile.ps1 /opt/microsoft/powershell/7/
sudo mkdir -p /usr/local/share/powershell/Scripts/ && sudo \cp -f .config/linux/config/ps_aliases_*.ps1 /usr/local/share/powershell/Scripts/

# *Setup profiles
.config/linux/scripts/setup_profiles.sh
