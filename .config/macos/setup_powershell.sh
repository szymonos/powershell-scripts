#!/usr/bin/env bash
: '
.config/macos/setup_powershell.sh --theme nerd --ps_modules "do-common do-linux"
'
if [[ $EUID -eq 0 ]]; then
  printf '\e[91mDo not run the script as root!\e[0m\n'
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

# set script working directory to workspace folder
SCRIPT_ROOT=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
pushd "$(readlink -f "${SCRIPT_ROOT}/../../")" >/dev/null

printf "\e[96minstalling packages...\e[0m\n"
.config/macos/scripts/install_brew.sh >/dev/null
.config/macos/scripts/install_exa.sh
.config/macos/scripts/install_omp.sh
.config/macos/scripts/install_pwsh.sh
printf "\e[96msetting up profile for all users...\e[0m\n"
sudo .config/linux/scripts/setup_omp.sh --theme $theme
sudo .config/macos/scripts/setup_profile_allusers.ps1
printf "\e[96msetting up profile for current user...\e[0m\n"
.config/linux/scripts/setup_profile_user.ps1
if [[ -n "$ps_modules" ]]; then
  printf "\e[96minstalling ps-modules...\e[0m\n"
  get_origin="git config --get remote.origin.url"
  origin=$(eval $get_origin)
  remote=${origin/powershell-scripts/ps-modules}
  if [ -d ../ps-modules ]; then
    pushd ../ps-modules >/dev/null
    if [ "$(eval $get_origin)" = "$remote" ]; then
      git reset --hard --quiet && git clean --force -d && git pull --quiet
    else
      ps_modules=''
    fi
    popd >/dev/null
  else
    git clone $remote ../ps-modules
  fi
  modules=($ps_modules)
  for mod in ${modules[@]}; do
    echo -e "\e[32m$mod\e[0m" >&2
    if [ "$mod" = 'do-common' ]; then
      sudo ../ps-modules/module_manage.ps1 "$mod" -CleanUp
    else
      ../ps-modules/module_manage.ps1 "$mod" -CleanUp
    fi
  done
fi

# restore working directory
popd >/dev/null
