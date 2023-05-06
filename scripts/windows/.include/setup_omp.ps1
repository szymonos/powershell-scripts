#Requires -Version 7.0
<#
.SYNOPSIS
Set oh-my-posh theme.

.EXAMPLE
scripts/windows/.include/setup_omp.ps1
$OmpTheme = 'powerline'
scripts/windows/.include/setup_omp.ps1 $OmpTheme
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
    if (Test-Path .config/omp_cfg/${OmpTheme}.omp.json -PathType Leaf) {
        # copy local theme
        Copy-Item -Path .config/omp_cfg/${OmpTheme}.omp.json -Destination $ompProfile -Force
    } else {
        # download theme from GitHub
        [Net.WebClient]::new().DownloadFile("https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${OmpTheme}.omp.json", $ompProfile)
    }
}

end {
    Pop-Location
}
