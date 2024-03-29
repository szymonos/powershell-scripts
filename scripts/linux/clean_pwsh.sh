#!/usr/bin/env bash
: '
scripts/linux/clean_pwsh.sh
'
if [ $EUID -eq 0 ]; then
  printf '\e[31;1mDo not run the script as root.\e[0m\n'
  exit 1
fi

# delete files and folders
rm -fr ~/.config/powershell 2>/dev/null
rm -fr ~/.local/share/powershell 2>/dev/null
sudo rm -fr /usr/local/share/powershell 2>/dev/null
sudo rm -f /usr/bin/pwsh 2>/dev/null
sudo rm -fr /usr/local/share/oh-my-posh 2>/dev/null
sudo rm -f /usr/bin/oh-my-posh 2>/dev/null

# determine system id
SYS_ID=$(grep -oPm1 '^ID(_LIKE)?=.*?\K(fedora|debian|ubuntu)' /etc/os-release)
case $SYS_ID in
fedora)
  sudo dnf remove -y powershell
  ;;
debian | ubuntu)
  export DEBIAN_FRONTEND=noninteractive
  sudo dpkg -r powershell
  ;;
*)
  sudo rm -fr /opt/microsoft/powershell 2>/dev/null
  ;;
esac
