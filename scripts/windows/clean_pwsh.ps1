#Requires -PSEdition Desktop
<#
.SYNOPSIS
Delete PowerShell Core and oh-my-posh.
.EXAMPLE
scripts/windows/clean_pwsh.ps1
#>

# *Uninstall PowerShell Core
if (Get-Command pwsh.exe -CommandType Application -ErrorAction SilentlyContinue) {
    # calculate path variables
    $profilePath = pwsh.exe -NoProfile -Command '[IO.Path]::GetDirectoryName($PROFILE)'
    # uninstall pwsh
    Get-Process pwsh.exe -ErrorAction SilentlyContinue | Stop-Process -Force
    winget uninstall --id Microsoft.PowerShell --force
    # delete folders
    Remove-Item -Force -Recurse $profilePath
}

# *Uninstall oh-my-posh
if (Get-Command oh-my-posh.exe -CommandType Application -ErrorAction SilentlyContinue) {
    Get-Process oh-my-posh -ErrorAction SilentlyContinue | Stop-Process -Force
    winget uninstall --id JanDeDobbeleer.OhMyPosh --force
}
