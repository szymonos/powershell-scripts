#!/bin/bash
: '
.config/linux/scripts/setup_profile.sh
'
if [[ $EUID -eq 0 ]]; then
  echo -e '\e[91mDo not run the script with sudo!\e[0m'
  exit 1
fi

# *Setup AllUsers profile
sudo pwsh -nop -c 'if (-not ((Get-Module PowerShellGet -ListAvailable -ErrorAction SilentlyContinue).Version.Major -ge 3)) { Install-Module PowerShellGet -AllowPrerelease -Scope AllUsers -Force }'
# install modules and setup experimental features
cat <<'EOF' | sudo pwsh -nop -c -
$WarningPreference = 'Ignore';
if (-not (Get-PSResourceRepository -Name PSGallery).Trusted) { Set-PSResourceRepository -Name PSGallery -Trusted };
if (-not ((Get-Module PSReadLine -ListAvailable -ErrorAction SilentlyContinue).Version.Minor -ge 2)) { Install-PSResource -Name PSReadLine -Scope AllUsers };
if (-not (Get-Module posh-git -ListAvailable)) { Install-PSResource -Name posh-git -Scope AllUsers };
if (-not $PSNativeCommandArgumentPassing) { Enable-ExperimentalFeature PSNativeCommandArgumentPassing };
if (-not $PSStyle) { Enable-ExperimentalFeature PSAnsiRenderingFileInfo };
EOF

# *Setup CurrentUser profile
cat <<'EOF' | pwsh -nop -c -
$WarningPreference = 'Ignore';
if (-not (Get-PSResourceRepository -Name PSGallery).Trusted) { Set-PSResourceRepository -Name PSGallery -Trusted };
if (-not $PSNativeCommandArgumentPassing) { Enable-ExperimentalFeature PSNativeCommandArgumentPassing };
if (-not $PSStyle) { Enable-ExperimentalFeature PSAnsiRenderingFileInfo };
if (Test-Path /usr/bin/kubectl) { (/usr/bin/kubectl completion powershell).Replace("'kubectl'", "'k'") >$PROFILE }
EOF
