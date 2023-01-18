#Requires -Version 7.0
<#
.SYNOPSIS
Set oh-my-posh theme.

.EXAMPLE
.config/windows/scripts/setup_omp.ps1
$OmpTheme = 'powerline'
.config/windows/scripts/setup_omp.ps1 $OmpTheme
#>
[CmdletBinding()]
param (
    [Parameter(Position = 0)]
    [string]$OmpTheme = 'base'
)

begin {
    # calculate omp theme location
    $ompProfile = [IO.Path]::Combine([IO.Path]::GetDirectoryName($PROFILE), 'theme.omp.json')

    # set location to workspace folder
    Push-Location "$PSScriptRoot/../../.."
}

process {
    if (Test-Path .config/.assets/omp_cfg/${OmpTheme}.omp.json -PathType Leaf) {
        # copy local theme
        Copy-Item -Path .config/.assets/omp_cfg/${OmpTheme}.omp.json -Destination $ompProfile -Force
    } else {
        # download theme from GitHub
        [Net.WebClient]::new().DownloadFile("https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${OmpTheme}.omp.json", $ompProfile)
    }
}

end {
    Pop-Location
}
