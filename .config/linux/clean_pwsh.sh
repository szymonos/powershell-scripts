#!/bin/bash
: '
.config/linux/clean_pwsh.sh
'
if [[ $(id -u) -eq 0 ]]; then
  echo -e '\e[91mDo not run the script with sudo!'
  exit 1
fi

rm -fr ~/.config/powershell 2>/dev/null
rm -fr ~/.local/share/powershell 2>/dev/null
sudo rm -fr /opt/microsoft/powershell 2>/dev/null
sudo rm -fr /usr/local/share/powershell 2>/dev/null
sudo rm -f /etc/profile.d/theme.omp.json 2>/dev/null
sudo rm -f /usr/bin/pwsh 2>/dev/null
sudo rm -f /usr/bin/oh-my-posh 2>/dev/null
