#!/bin/bash
: '
sudo .config/linux/scripts/setup_omp.sh --theme_font "powerline"
'
if [[ $EUID -ne 0 ]]; then
  echo -e '\e[91mRun the script with sudo!\e[0m'
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

# path variables
OH_MY_POSH_PATH='/usr/local/share/oh-my-posh'
case $theme_font in
base)
  OMP_THEME='.config/.assets/theme.omp.json'
  ;;
powerline)
  OMP_THEME='.config/.assets/theme-pl.omp.json'
  ;;
esac

# *Copy oh-my-posh theme
if [ -f $OMP_THEME ]; then
  # oh-my-posh profile
  \mkdir -p $OH_MY_POSH_PATH
  \cp -f $OMP_THEME "$OH_MY_POSH_PATH/theme.omp.json"
fi
