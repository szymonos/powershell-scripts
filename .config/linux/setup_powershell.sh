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

# *Install PowerShell
sudo .config/linux/scripts/install_pwsh.sh

# *Setup profile
.config/linux/scripts/setup_profile.sh

# *Copy assets
# calculate variables
OMP_PROFILE=$([[ "$1" = 'pl' ]] && '.config/.assets/theme-pl.omp.json' || '.config/.assets/theme.omp.json')
PROFILE_PATH=$(pwsh -nop -c '[IO.Path]::GetDirectoryName($PROFILE.AllUsersAllHosts)')
SCRIPTS_PATH=$(pwsh -nop -c '$env:PSModulePath.Split(':')[1].Replace('Modules', 'Scripts')')
# create scripts folder
sudo mkdir -p $SCRIPTS_PATH

# oh-my-posh profile
sudo \cp -f "$OMP_PROFILE" "$PROFILE_PATH/theme.omp.json"
# PowerShell profile
sudo \cp -f .config/.assets/profile.ps1 $PROFILE_PATH
# PowerShell functions
sudo \cp -f .config/.assets/ps_aliases_common.ps1 $SCRIPTS_PATH
sudo \cp -f .config/.assets/ps_aliases_linux.ps1 $SCRIPTS_PATH
# git functions
if type git &>/dev/null; then
  sudo \cp -f .config/.assets/ps_aliases_git.ps1 $SCRIPTS_PATH
fi
# kubectl functions
if type kubectl &>/dev/null; then
  sudo \cp -f .config/.assets/ps_aliases_kubectl.ps1 $SCRIPTS_PATH
  # add powershell kubectl autocompletion
  pwsh -nop -c '(kubectl completion powershell).Replace("''kubectl''", "''k''") > $PROFILE.CurrentUserAllHosts'

fi
