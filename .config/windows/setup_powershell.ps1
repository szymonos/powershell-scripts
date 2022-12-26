#Requires -PSEdition Desktop
<#
.SYNOPSIS
Script synopsis.
.PARAMETER OmpTheme
Choose if oh-my-posh prompt theme should use base or powerline fonts.
Available values: 'base', 'powerline'
.PARAMETER PSModules
List of PowerShell modules from ps-modules repository to be installed.
.EXAMPLE
.config/windows/setup_powershell.ps1
$OmpTheme = 'powerline'
.config/windows/setup_powershell.ps1 -t $OmpTheme
$PSModules = 'do-common do-win'
.config/windows/setup_powershell.ps1 -m $PSModules
.config/windows/setup_powershell.ps1 -m $PSModules -t $OmpTheme
#>
[CmdletBinding()]
param (
    [Alias('t')]
    [string]$OmpTheme,

    [Alias('m')]
    [string]$PSModules
)

begin {
    # set location to workspace folder
    $workspaceFolder = Split-Path (Split-Path $PSScriptRoot)
    if ($workspaceFolder -ne $PWD.Path) {
        $startWorkingDirectory = $PWD
        Write-Verbose "Setting working directory to '$($workspaceFolder.Replace($HOME, '~'))'."
        Set-Location $workspaceFolder
    }
    # source common functions
    . .include/ps_functions.ps1
}

process {
    # *Install oh-my-posh
    if ($OmpTheme) {
        .config/windows/scripts/install_omp.ps1
    }

    # *Install PowerShell
    .config/windows/scripts/install_pwsh.ps1

    # *Setup profile
    Update-SessionEnvironment
    pwsh.exe -NoProfile .config/windows/scripts/setup_profile.ps1 @PSBoundParameters
}

end {
    if ($startWorkingDirectory) {
        Set-Location $startWorkingDirectory
    }
}
