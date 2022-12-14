<#
.SYNOPSIS
Install oh-my-posh using winget.
.EXAMPLE
.config/windows/scripts/install_omp.ps1
#>
$app = 'oh-my-posh'

$rel = Invoke-CommandRetry -Verbose {
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
