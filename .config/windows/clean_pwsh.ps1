#!/usr/bin/pwsh -nop
<#
.SYNOPSIS
Script synopsis.
.EXAMPLE
.config/windows/clean_pwsh.ps1
#>

# calculate path variables
$cuProfilePath = pwsh -NoProfile -Command '[IO.Path]::GetDirectoryName($PROFILE.CurrentUserAllHosts)'

# uninstall programs
Get-Process pwsh -ErrorAction SilentlyContinue | Stop-Process -Force
winget uninstall --id Microsoft.PowerShell --force
Get-Process oh-my-posh -ErrorAction SilentlyContinue | Stop-Process -Force
winget uninstall --id JanDeDobbeleer.OhMyPosh --force

# delete folders
Remove-Item -Force -Recurse $cuProfilePath
Remove-Item -Force -Recurse 'C:\Program Files\PowerShell'
