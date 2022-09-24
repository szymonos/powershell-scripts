#!/bin/bash
: '
.config/linux/clean_pwsh.sh
'
if [[ $(id -u) -eq 0 ]]; then
  echo -e '\e[91mDo not run the script with sudo!'
  exit 1
fi

# delete files and folders
rm -fr ~/.config/powershell 2>/dev/null
rm -fr ~/.local/share/powershell 2>/dev/null
sudo rm -fr /usr/local/share/powershell 2>/dev/null
sudo rm -f /etc/profile.d/theme.omp.json 2>/dev/null
sudo rm -f /usr/bin/pwsh 2>/dev/null
sudo rm -f /usr/bin/oh-my-posh 2>/dev/null

# determine system id
SYS_ID=$(grep -oPm1 '^ID(_LIKE)?=.*\K(alpine|arch|fedora|debian|ubuntu|opensuse)' /etc/os-release)
case $SYS_ID in
fedora)
  sudo dnf remove -y powershell
  ;;
debian | ubuntu)
  sudo dpkg -r powershell
  ;;
*)
  sudo rm -fr /opt/microsoft/powershell 2>/dev/null
  ;;
esac
