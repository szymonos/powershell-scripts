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
# ~set up PowerShell without oh-my-posh
scripts/windows/setup_powershell.ps1
$PSModules = @('do-common')
scripts/windows/setup_powershell.ps1 -m $PSModules
scripts/windows/setup_powershell.ps1 -m $PSModules -UpdateModules
# ~set up PowerShell with oh-my-posh
$OmpTheme = 'nerd'
scripts/windows/setup_powershell.ps1 -t $OmpTheme
scripts/windows/setup_powershell.ps1 -t $OmpTheme -m $PSModules
scripts/windows/setup_powershell.ps1 -t $OmpTheme -m $PSModules -UpdateModules
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
    scripts/windows/.include/install_pwsh.ps1

    # *Setup profile
    Update-SessionEnvironment
    $cmd = 'scripts/windows/.include/setup_profile.ps1'
    if ($OmpTheme) { $cmd += " -OmpTheme '$OmpTheme'" }
    if ($PSModules) { $cmd += " -PSModules @($($PSModules | Join-String -SingleQuote -Separator ','))" }
    pwsh.exe -NoProfile -Command $cmd
}

end {
    Pop-Location
}
