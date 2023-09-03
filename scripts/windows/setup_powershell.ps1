#Requires -PSEdition Desktop
<#
.SYNOPSIS
Install the latest PowerShell, oh-my-posh if specified and setup profile on Windows.

.PARAMETER OmpTheme
Specify oh-my-posh theme to be installed, from themes available on the page.
There are also two baseline profiles included: base and powerline.
.PARAMETER PSModules
List of PowerShell modules from ps-modules repository to be installed.
.PARAMETER UpdateModules
Switch, whether to update installed PowerShell modules.

.EXAMPLE
# :set up PowerShell
scripts/windows/setup_powershell.ps1
scripts/windows/setup_powershell.ps1 -UpdateModules
# :set up PowerShell with oh-my-posh
$OmpTheme = 'nerd'
scripts/windows/setup_powershell.ps1 -t $OmpTheme
scripts/windows/setup_powershell.ps1 -t $OmpTheme -UpdateModules
# :specify modules from ps-modules repo
$PSModules = @('do-common')
scripts/windows/setup_powershell.ps1 -m $PSModules
scripts/windows/setup_powershell.ps1 -m $PSModules -UpdateModules
#>
[CmdletBinding()]
param (
    [Alias('t')]
    [string]$OmpTheme,

    [Alias('m')]
    [string[]]$PSModules = @('do-common', 'do-win'),

    [switch]$UpdateModules
)

begin {
    # set location to workspace folder
    Push-Location "$PSScriptRoot/../.."
    # source common functions
    . scripts/windows/.include/ps_functions.ps1
}

process {
    # *Install PowerShell
    Write-Host 'installing pwsh...' -ForegroundColor Cyan
    # check if latest pwsh installed
    if (Get-Command pwsh.exe -CommandType Application -ErrorAction SilentlyContinue) {
        $retryCount = 0
        do {
            $rel = (Invoke-RestMethod 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest').tag_name -replace '^v'
            $retryCount++
        } until ($rel -or $retryCount -eq 10)
        $ver = pwsh.exe -nop -c '$PSVersionTable.PSVersion.ToString()'
        if ($rel -eq $ver) {
            $skipInstall = $true
        }
    }

    if ($skipInstall) {
        Write-Host "PowerShell v$ver is already latest."
    } else {
        if (Test-IsAdmin) {
            scripts/windows/.include/install_pwsh.ps1
        } else {
            if (Get-Command 'gsudo.exe' -CommandType Application -ErrorAction SilentlyContinue) {
                gsudo powershell.exe -NoProfile scripts/windows/.include/install_pwsh.ps1
            } else {
                $scriptPath = Resolve-Path scripts/windows/.include/install_pwsh.ps1
                Start-Process powershell.exe "-NoProfile -File `"$scriptPath`"" -Verb RunAs
            }
        }
    }

    # *Setup profile
    Update-SessionEnvironment
    $cmd = 'scripts/windows/.include/setup_profile.ps1'
    if ($OmpTheme) { $cmd += " -OmpTheme '$OmpTheme'" }
    if ($PSModules) { $cmd += " -PSModules @($([String]::Join(',', $PSModules.ForEach({ "'$_'" }))))" }
    if ($UpdateModules) { $cmd += ' -UpdateModules' }
    pwsh.exe -NoProfile -Command $cmd
}

end {
    Pop-Location
}
