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
$OmpTheme = 'none'
$OmpTheme = 'powerline'
.config/windows/setup_powershell.ps1 $OmpTheme
$PSModules = 'do-common do-win'
.config/windows/setup_powershell.ps1 $OmpTheme -m $PSModules
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory, Position = 0)]
    [ValidateSet('none', 'base', 'powerline')]
    [string]$OmpTheme,

    [Alias('m')]
    [string]$PSModules
)

begin {
    # source common functions
    . .include/ps_functions.ps1
    # set location to workspace folder
    $workspaceFolder = Split-Path (Split-Path $PSScriptRoot)
    if ($workspaceFolder -ne $PWD.Path) {
        $startWorkingDirectory = $PWD
        Write-Verbose "Setting working directory to '$($workspaceFolder.Replace($HOME, '~'))'."
        Set-Location $workspaceFolder
    }
}

process {
    # *Install oh-my-posh
    if ($OmpTheme -ne 'none') {
        .config/windows/scripts/install_omp.ps1
    }

    # *Install PowerShell
    .config/windows/scripts/install_pwsh.ps1

    # *Setup profile
    Update-SessionEnvironment
    $param = @{ OmpTheme = $OmpTheme }
    if ($PSModules) {
        $param.PSModules = $PSModules
    }
    pwsh.exe -NoProfile .config/windows/scripts/setup_profile.ps1 @param
}

end {
    if ($startWorkingDirectory) {
        Set-Location $startWorkingDirectory
    }
}
