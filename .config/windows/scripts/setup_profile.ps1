<#
.SYNOPSIS
Script synopsis.
.EXAMPLE
.config/windows/scripts/setup_profile.ps1
#>
pwsh -NoProfile -Command 'Install-Module PowerShellGet -AllowPrerelease -Force -WarningAction SilentlyContinue'

pwsh -NoProfile -Command @'
Write-Host "Set PSGallery Trusted" && Set-PSResourceRepository -Name PSGallery -Trusted -WarningAction SilentlyContinue;
Write-Host "Install PSReadLine" && Install-PSResource -Name PSReadLine -Quiet -WarningAction SilentlyContinue;
Write-Host "Install posh-git" && Install-PSResource -Name posh-git -Quiet -WarningAction SilentlyContinue
'@
