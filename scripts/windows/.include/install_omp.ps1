<#
.SYNOPSIS
Install oh-my-posh using winget.
.EXAMPLE
scripts/windows/.include/install_omp.ps1
#>
$ErrorActionPreference = 'Stop'

# dot-source ps_functions script
. "$PSScriptRoot/ps_functions.ps1"

$app = 'oh-my-posh'

$rel = Invoke-CommandRetry {
    (Invoke-RestMethod 'https://api.github.com/repos/JanDeDobbeleer/oh-my-posh/releases/latest').tag_name -replace '^v'
}

if (Get-Command oh-my-posh.exe -CommandType Application -ErrorAction SilentlyContinue) {
    $ver = oh-my-posh.exe version
    if ($rel -eq $ver) {
        Write-Host "$app v$ver is already latest"
        exit 0
    } else {
        winget.exe upgrade --id JanDeDobbeleer.OhMyPosh
    }
} else {
    winget.exe install --id JanDeDobbeleer.OhMyPosh
}
