#!/usr/bin/env zsh
: '
.config/macos/setup_powershell.sh --theme powerline --ps_modules "do-common"
'
if [[ $EUID -eq 0 ]]; then
  echo -e '\e[91mDo not run the script as root!\e[0m'
  exit 1
fi

# parse named parameters
theme=${theme:-base}
ps_modules=${ps_modules}
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

echo -e "\e[32minstalling brew...\e[0m"
.config/macos/scripts/install_brew.sh
echo -e "\e[32minstalling pwsh packages...\e[0m"
.config/macos/scripts/install_exa.sh
.config/macos/scripts/install_omp.sh
.config/macos/scripts/install_pwsh.sh
echo -e "\e[32msetting up profile for all users...\e[0m"
sudo .config/linux/scripts/setup_omp.sh --theme $theme
sudo .config/macos/scripts/setup_profile_allusers.ps1
echo -e "\e[32msetting up profile for current user...\e[0m"
.config/linux/scripts/setup_profile_user.ps1
if [[ -n "$ps_modules" ]]; then
  if [ ! -d ../ps-modules ]; then
    remote=$(git config --get remote.origin.url)
    git clone ${remote/powershell-scripts/ps-modules} ../ps-modules
  fi
  echo -e "\e[32minstalling PowerShell modules...\e[0m"
  mods=($ps_modules)
  for mod in ${mods[@]}; do
    if [ "$mod" = 'do-common' ]; then
      sudo ../ps-modules/module_manage.ps1 "$mod" -CleanUp
    else
      ../ps-modules/module_manage.ps1 "$mod" -CleanUp
    fi
  done
fi
