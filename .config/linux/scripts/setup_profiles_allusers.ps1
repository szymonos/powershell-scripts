#!/usr/bin/env -S pwsh -nop
<#
.SYNOPSIS
Setting up PowerShell for the all users.
.EXAMPLE
sudo .config/linux/scripts/setup_profiles_allusers.ps1
#>
$ErrorActionPreference = 'SilentlyContinue'
$WarningPreference = 'Ignore'

# path variables
$SCRIPTS_PATH = '/usr/local/share/powershell/Scripts'
# determine folder with config files

# *Copy global profiles
# PowerShell profile
Copy-Item .config/.assets/profile.ps1 -Destination $PROFILE.AllUsersAllHosts
# PowerShell functions
New-Item $SCRIPTS_PATH -ItemType Directory | Out-Null
Copy-Item .config/.assets/ps_aliases_common.ps1 -Destination $SCRIPTS_PATH
Copy-Item .config/.assets/ps_aliases_linux.ps1 -Destination $SCRIPTS_PATH
# git functions
if (Test-Path /usr/bin/git -PathType Leaf) {
    Copy-Item .config/.assets/ps_aliases_git.ps1 -Destination $SCRIPTS_PATH
}
# kubectl functions
if (Test-Path /usr/bin/kubectl -PathType Leaf) {
    Copy-Item .config/.assets/ps_aliases_kubectl.ps1 -Destination $SCRIPTS_PATH
}

# *PowerShell profile
while (-not ((Get-Module PowerShellGet -ListAvailable).Version.Major -ge 3)) {
    Write-Host 'installing PowerShellGet...'
    Install-Module PowerShellGet -AllowPrerelease -Scope AllUsers -Force
}
if (-not (Get-PSResourceRepository -Name PSGallery).Trusted) {
    Write-Host 'setting PSGallery trusted...'
    Set-PSResourceRepository -Name PSGallery -Trusted
}
while (-not (Get-Module posh-git -ListAvailable)) {
    Write-Host 'installing posh-git...'
    Install-PSResource -Name posh-git -Scope AllUsers
}
