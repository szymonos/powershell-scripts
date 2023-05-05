#!/usr/bin/env bash
: '
# :default setup without setting oh-my-posh theme
.config/linux/setup_powershell.sh
# :setup with oh-my-posh theme using base fonts
.config/linux/setup_powershell.sh --omp_theme base
# :setup with oh-my-posh theme using powerline fonts
.config/linux/setup_powershell.sh --omp_theme powerline
# :setup with oh-my-posh theme using nerd fonts
.config/linux/setup_powershell.sh --omp_theme nerd
# :you can specify any themes from https://ohmyposh.dev/docs/themes/ (e.g. atomic)
.config/linux/setup_powershell.sh --omp_theme atomic
'
if [ $EUID -eq 0 ]; then
  printf '\e[31;1mDo not run the script as root.\e[0m\n'
  exit 1
else
  user=$(id -un)
fi

# parse named parameters
omp_theme=${omp_theme}
ps_modules=${ps_modules:-'do-common do-linux'}
while [ $# -gt 0 ]; do
  if [[ $1 == *"--"* ]]; then
    param="${1/--/}"
    declare $param="$2"
  fi
  shift
done

# set script working directory to workspace folder
SCRIPT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)
pushd "$(cd "${SCRIPT_ROOT}/../../" && pwd)" >/dev/null

if [[ -n "$omp_theme" || -f /usr/bin/oh-my-posh ]]; then
  printf "\e[96minstalling oh-my-posh...\e[0m\n"
  sudo .config/linux/scripts/install_omp.sh >/dev/null
  if [ -n "$omp_theme" ]; then
    sudo .config/linux/scripts/setup_omp.sh --theme $omp_theme --user $user
  fi
fi
printf "\e[96minstalling packages...\e[0m\n"
sudo .config/linux/scripts/install_exa.sh >/dev/null
sudo .config/linux/scripts/install_pwsh.sh >/dev/null
printf "\e[96msetting up profile for all users...\e[0m\n"
sudo .config/linux/scripts/setup_profile_allusers.ps1 -UserName $user
printf "\e[96msetting up profile for the current user...\e[0m\n"
.config/linux/scripts/setup_profile_user.ps1
# install powershell modules
if [ -f /usr/bin/pwsh ]; then
  modules=($ps_modules)
  [ -f /usr/bin/git ] && modules+=(aliases-git) || true
  [ -f /usr/bin/kubectl ] && modules+=(aliases-kubectl) || true
  if [[ -n "$modules" && -f /usr/bin/git ]]; then
    printf "\e[96minstalling ps-modules...\e[0m\n"
    # determine if ps-modules repository exist and clone if necessary
    get_origin="git config --get remote.origin.url"
    origin=$(eval $get_origin)
    remote=${origin/powershell-scripts/ps-modules}
    if [ -d ../ps-modules ]; then
      pushd ../ps-modules >/dev/null
      if [ "$(eval $get_origin)" = "$remote" ]; then
        git fetch -q && git reset --hard -q "origin/$(git branch --show-current)"
      else
        modules=()
      fi
      popd >/dev/null
    else
      git clone $remote ../ps-modules
    fi
    # install do-common module for all users
    if grep -qw 'do-common' <<<$ps_modules; then
      printf "\e[3;32mAllUsers\e[23m    : do-common\e[0m\n"
      sudo ../ps-modules/module_manage.ps1 'do-common' -CleanUp
    fi
    # install rest of the modules for the current user
    modules=(${modules[@]/do-common/})
    if [ -n "$modules" ]; then
      # Convert the modules array to a comma-separated string with quoted elements
      printf "\e[3;32mCurrentUser\e[23m : ${modules[*]}\e[0m\n"
      mods=''
      for element in "${modules[@]}"; do
        mods="$mods'$element',"
      done
      pwsh -nop -c "@(${mods%,}) | ../ps-modules/module_manage.ps1 -CleanUp"
    fi
  fi
fi

# restore working directory
popd >/dev/null
