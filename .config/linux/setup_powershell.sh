#!/bin/bash
: '
.config/linux/setup_powershell.sh --theme_font powerline
'
if [[ $EUID -eq 0 ]]; then
  echo -e '\e[91mDo not run the script with sudo!\e[0m'
  exit 1
fi

# parse named parameters
theme_font=${theme_font:-base}
while [ $# -gt 0 ]; do
  if [[ $1 == *"--"* ]]; then
    param="${1/--/}"
    declare $param="$2"
  fi
  shift
done

# correct script working directory if needed
WORKSPACE_FOLDER=$(dirname "$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")")
[[ "$PWD" = "$WORKSPACE_FOLDER" ]] || cd "$WORKSPACE_FOLDER"

echo -e "\e[32minstalling pwsh packages...\e[0m"
sudo .assets/provision/install_omp.sh
sudo .assets/provision/install_pwsh.sh
echo -e "\e[32msetting up profile for all users...\e[0m"
sudo .assets/provision/setup_omp.sh --theme_font $theme_font
sudo .assets/provision/setup_profiles_allusers.ps1
echo -e "\e[32msetting up profile for current user...\e[0m"
.assets/provision/setup_profiles_user.ps1
