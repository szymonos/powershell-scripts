#!/bin/bash
: '
.config/linux/install_pwsh.sh      #* install basic oh-my-posh profile
.config/linux/install_pwsh.sh pl   #* install powerline oh-my-posh profile
'
if [[ $(id -u) -eq 0 ]]; then
  echo -e '\e[91mDo not run the script with sudo!'
  exit 1
fi

# *Install oh-my-posh
sudo .config/linux/scripts/install_omp.sh
# copy omp theme
if [ "$1" = 'pl' ]; then
  sudo \cp -f .assets/config/theme-pl.omp.json /etc/profile.d/theme.omp.json
else
  sudo \cp -f .assets/config/theme.omp.json /etc/profile.d/theme.omp.json
fi

# *PowerShell
sudo .config/linux/scripts/install_pwsh.sh
# copy profile and aliases
sudo \cp -f .config/linux/config/profile.ps1 /opt/microsoft/powershell/7/
sudo mkdir -p /usr/local/share/powershell/Scripts/ && sudo \cp -f .config/linux/config/ps_aliases_*.ps1 /usr/local/share/powershell/Scripts/

# *Setup profiles
.config/linux/scripts/setup_profile_allusers.sh
