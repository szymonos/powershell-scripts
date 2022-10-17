#!/bin/bash
: '
.config/linux/scripts/setup_profile.sh
'
if [[ $EUID -eq 0 ]]; then
  echo -e '\e[91mDo not run the script with sudo!\e[0m'
  exit 1
fi

# *Setup AllUsers profile
sudo pwsh -nop -c 'Write-Host "Install PowerShellGet" && Install-Module PowerShellGet -AllowPrerelease -Scope AllUsers -Force -WarningAction SilentlyContinue'
# install modules and setup experimental features
cat <<'EOF' | sudo pwsh -nop -c -
$WarningPreference = 'Ignore';
Write-Host 'Set PSGallery Trusted' && Set-PSResourceRepository -Name PSGallery -Trusted;
Write-Host 'Install PSReadLine' && Install-PSResource -Name PSReadLine -Scope AllUsers -Quiet;
Write-Host 'Install posh-git' && Install-PSResource -Name posh-git -Scope AllUsers -Quiet;
Write-Host 'Enable ExperimentalFeature' && Enable-ExperimentalFeature PSAnsiRenderingFileInfo, PSNativeCommandArgumentPassing
EOF

# *Setup CurrentUser profile
cat <<'EOF' | pwsh -nop -c -
$WarningPreference = 'Ignore';
Set-PSResourceRepository -Name PSGallery -Trusted;
Enable-ExperimentalFeature PSAnsiRenderingFileInfo, PSNativeCommandArgumentPassing;
if (Test-Path /usr/bin/kubectl -PathType Leaf) {
    (/usr/bin/kubectl completion powershell).Replace("'kubectl'", "'k'") >$PROFILE
}
EOF
