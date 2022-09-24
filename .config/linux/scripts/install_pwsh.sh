#!/bin/bash
: '
sudo .config/linux/scripts/install_pwsh.sh
'
if [[ $(id -u) -ne 0 ]]; then
  echo -e '\e[91mRun the script with sudo!'
  exit 1
fi

APP='pwsh'
while [[ -z $REL ]]; do
  REL=$(curl -sk https://api.github.com/repos/PowerShell/PowerShell/releases/latest | grep -Po '"tag_name": *"v\K.*?(?=")')
done

if type $APP &>/dev/null; then
  VER=$(pwsh -nop -c '$PSVersionTable.PSVersion.ToString()')
  if [ $REL = $VER ]; then
    echo "The latest $APP v$VER is already installed!"
    exit 0
  fi
fi

echo "Install $APP v$REL"
# determine system id
SYS_ID=$(grep -oPm1 '^ID(_LIKE)?=.*\K(alpine|arch|fedora|debian|ubuntu|opensuse)' /etc/os-release)

case $SYS_ID in
fedora)
  sudo dnf install -y "https://github.com/PowerShell/PowerShell/releases/download/v${REL}/powershell-${REL}-1.rh.x86_64.rpm"
  ;;
debian | ubuntu)
  curl -Lsk -o powershell.deb "https://github.com/PowerShell/PowerShell/releases/download/v${REL}/powershell_${REL}-1.deb_amd64.deb"
  sudo dpkg -i powershell.deb && rm -f powershell.deb
  ;;
alpine)
  sudo apk add --no-cache \
    ca-certificates \
    less \
    ncurses-terminfo-base \
    krb5-libs \
    libgcc \
    libintl \
    libssl1.1 \
    libstdc++ \
    tzdata \
    userspace-rcu \
    zlib \
    icu-libs \
    curl
  sudo apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache \
    lttng-ust
  while [[ ! -f powershell.tar.gz ]]; do
    curl -Lsk -o powershell.tar.gz "https://github.com/PowerShell/PowerShell/releases/download/v${REL}/powershell-${REL}-linux-alpine-x64.tar.gz"
  done
  sudo mkdir -p /opt/microsoft/powershell/7
  sudo tar zxf powershell.tar.gz -C /opt/microsoft/powershell/7 && rm -f powershell.tar.gz
  sudo chmod +x /opt/microsoft/powershell/7/pwsh
  [ -f /usr/bin/pwsh ] || sudo ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
*)
  [ "$SYS_ID" = 'opensuse' ] && zypper in -y libicu
  while [[ ! -f powershell.tar.gz ]]; do
    curl -Lsk -o powershell.tar.gz "https://github.com/PowerShell/PowerShell/releases/download/v${REL}/powershell-${REL}-linux-x64.tar.gz"
  done
  sudo mkdir -p /opt/microsoft/powershell/7
  sudo tar zxf powershell.tar.gz -C /opt/microsoft/powershell/7 && rm -f powershell.tar.gz
  sudo chmod +x /opt/microsoft/powershell/7/pwsh
  [ -f /usr/bin/pwsh ] || sudo ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
  ;;
esac
