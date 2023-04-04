#!/usr/bin/env bash
: '
# *default setup with oh-my-posh theme using baseline fonts
.config/linux/setup_powershell.sh --ps_modules "do-common do-linux"
# *setup with oh-my-posh theme using powerline fonts
.config/linux/setup_powershell.sh --theme powerline --ps_modules "do-common do-linux"
# *setup with oh-my-posh theme using nerd fonts
.config/linux/setup_powershell.sh --theme nerd --ps_modules "do-common do-linux"
# *you can specify any themes from https://ohmyposh.dev/docs/themes/ (e.g. atomic)
.config/linux/setup_powershell.sh --theme atomic --ps_modules "do-common do-linux"
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

# set script working directory to workspace folder
SCRIPT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)
pushd "$(cd "${SCRIPT_ROOT}/../../" && pwd)" >/dev/null

echo -e "\e[96minstalling packages...\e[0m"
sudo .config/linux/scripts/install_exa.sh >/dev/null
sudo .config/linux/scripts/install_omp.sh >/dev/null
sudo .config/linux/scripts/install_pwsh.sh >/dev/null
echo -e "\e[96msetting up profile for all users...\e[0m"
sudo .config/linux/scripts/setup_omp.sh --theme $theme
sudo .config/linux/scripts/setup_profile_allusers.ps1
echo -e "\e[96msetting up profile for current user...\e[0m"
.config/linux/scripts/setup_profile_user.ps1
# install powershell modules
if [ -f /usr/bin/pwsh ]; then
  modules=($ps_modules)
  [ -f /usr/bin/git ] && modules+=(aliases-git) || true
  [ -f /usr/bin/kubectl ] && modules+=(aliases-kubectl) || true
  if [[ -n $modules ]]; then
    echo -e "\e[96minstalling ps-modules...\e[0m"
    # determine if ps-modules repository exist and clone if necessary
    get_origin="git config --get remote.origin.url"
    origin=$(eval $get_origin)
    remote=${origin/vagrant-scripts/ps-modules}
    if [ -d ../ps-modules ]; then
      pushd ../ps-modules >/dev/null
      if [ "$(eval $get_origin)" = "$remote" ]; then
        git reset --hard --quiet && git clean --force -d && git pull --quiet
      else
        modules=()
      fi
      popd >/dev/null
    else
      git clone $remote ../ps-modules
    fi
    # install modules
    for mod in ${modules[@]}; do
      echo -e "\e[32m$mod\e[0m" >&2
      if [ "$mod" = 'do-common' ]; then
        sudo ../ps-modules/module_manage.ps1 "$mod" -CleanUp
      else
        ../ps-modules/module_manage.ps1 "$mod" -CleanUp
      fi
    done
  fi
fi

# restore working directory
popd >/dev/null
