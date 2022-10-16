#Requires -PSEdition Desktop
<#
.SYNOPSIS
Script synopsis.
.EXAMPLE
.config/windows/clean_pwsh.ps1
#>

# *Uninstall PowerShell Core
if (Get-Command pwsh.exe -CommandType Application -ErrorAction SilentlyContinue) {
    # calculate path variables
    $cuProfilePath = pwsh -NoProfile -Command '[IO.Path]::GetDirectoryName($PROFILE.CurrentUserAllHosts)'
    # uninstall pwsh
    Get-Process pwsh -ErrorAction SilentlyContinue | Stop-Process -Force
    winget uninstall --id Microsoft.PowerShell --force
    # delete folders
    Remove-Item -Force -Recurse $cuProfilePath
    Remove-Item -Force -Recurse 'C:\Program Files\PowerShell'
}

# *Uninstall oh-my-posh
if (Get-Command oh-my-posh.exe -CommandType Application -ErrorAction SilentlyContinue) {
    Get-Process oh-my-posh -ErrorAction SilentlyContinue | Stop-Process -Force
    winget uninstall --id JanDeDobbeleer.OhMyPosh --force
}
