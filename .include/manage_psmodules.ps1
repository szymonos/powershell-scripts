#!/usr/bin/env -S pwsh -nop
#Requires -Version 7.0
<#
.SYNOPSIS
Script for updating PowerShell modules and cleaning-up old versions.
.EXAMPLE
.include/manage_psmodules.ps1       # *update and clean up modules
.include/manage_psmodules.ps1 -u    # *update modules only
.include/manage_psmodules.ps1 -c    # *clean up modules only
#>
param (
    [Alias('u')]
    [switch]$Update,

    [Alias('c')]
    [switch]$CleanUp
)
# source common functions
. .include/ps_functions.ps1

# set update scope
if (Test-IsAdmin) {
    $param = @{ Scope = 'AllUsers' }
} else {
    $param = @{ Scope = 'CurrentUser' }
}

if (-not $CleanUp) {
    Write-Host "updating modules in the `e[1m$($param.Scope)`e[22m scope..." -ForegroundColor DarkYellow
    Update-PSResource @param -AcceptLicense
    Write-Host "checking pre-release versions..." -ForegroundColor DarkYellow
    $prerelease = Get-PSResource @param | Where-Object PrereleaseLabel
    foreach ($mod in $prerelease) {
        Write-Host "- $($mod.Name)"
        (Find-PSResource -Name $mod.Name -Prerelease) | ForEach-Object {
            if ($_.Version.ToString() -notmatch $mod.Version.ToString()) {
                Write-Host "found newer version: `e[1m$($_.Version)`e[22m" -ForegroundColor DarkGreen
                Update-PSResource @param -Name $mod.Name -Prerelease -AcceptLicense -Force
            }
        }
    }
}

if (-not $Update) {
    Write-Host "getting duplicate modules..." -ForegroundColor DarkYellow
    $dupedModules = Get-PSResource @param | Group-Object -Property Name | Where-Object Count -GT 1 | Select-Object -ExpandProperty Name

    foreach ($mod in $dupedModules) {
        $allVersions = Get-PSResource @param -Name $mod
        $latestVersion = ($allVersions | Sort-Object PublishedDate)[-1].Version

        Write-Host "`n`e[4m$($mod)`e[24m - $($allVersions.Count) versions of the module found, latest: `e[1mv$latestVersion`e[22m" -ForegroundColor DarkYellow
        Write-Host 'uninstalling...'
        foreach ($v in $allVersions.Where({ $_.Version -ne $latestVersion })) {
            Write-Host "- `e[95mv$($v.Version)`e[0m"
            Uninstall-PSResource @param -Name $v.Name -Version ($v.Prerelease ? "$($v.Version)-$($v.Prerelease)" : "$($v.Version)") -SkipDependencyCheck
        }
    }
}

Write-Host "Done." -ForegroundColor Green
