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
$PSModules = @('do-common', 'do-win')
# ~set up PowerShell without oh-my-posh
.config/windows/setup_powershell.ps1
.config/windows/setup_powershell.ps1 -m $PSModules
.config/windows/setup_powershell.ps1 -m $PSModules -UpdateModules
# ~set up PowerShell with oh-my-posh
$OmpTheme = 'powerline'
.config/windows/setup_powershell.ps1 -t $OmpTheme
.config/windows/setup_powershell.ps1 -t $OmpTheme -m $PSModules
.config/windows/setup_powershell.ps1 -t $OmpTheme -m $PSModules -UpdateModules
#>
[CmdletBinding()]
param (
    [Alias('t')]
    [string]$OmpTheme,

    [Alias('m')]
    [string[]]$PSModules,

    [switch]$UpdateModules
)

begin {
    # set location to workspace folder
    Push-Location "$PSScriptRoot/../.."
    # source common functions
    . .include/ps_functions.ps1
}

process {
    # *Install PowerShell
    Write-Host 'installing pwsh...' -ForegroundColor Cyan
    .config/windows/scripts/install_pwsh.ps1

    # *Setup profile
    Update-SessionEnvironment
    pwsh.exe -NoProfile .config/windows/scripts/setup_profile.ps1 @PSBoundParameters
}

end {
    Pop-Location
}
