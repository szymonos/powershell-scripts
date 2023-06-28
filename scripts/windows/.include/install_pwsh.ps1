#Requires -RunAsAdministrator
#Requires -PSEdition Desktop
<#
.SYNOPSIS
Install PowerShell Core.
.EXAMPLE
scripts/windows/.include/install_pwsh.ps1
#>
$ErrorActionPreference = 'Stop'

$app = 'pwsh'

$retryCount = 0
do {
    $rel = (Invoke-RestMethod 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest').tag_name -replace '^v'
    $retryCount++
} until ($rel -or $retryCount -eq 10)

if (Get-Command pwsh.exe -CommandType Application -ErrorAction SilentlyContinue) {
    $ver = pwsh.exe -nop -c '$PSVersionTable.PSVersion.ToString()'
    if ($rel -eq $ver) {
        Write-Host "$app v$ver is already latest"
        exit 0
    }
}

if ($pwshp = Get-Process pwsh -ErrorAction SilentlyContinue) {
    $msg = 'Do you want to terminate existing pwsh process(es)? [y/N]'
    if ((Read-Host -Prompt $msg) -eq 'y') {
        $pwshp | Stop-Process -Force
    } else {
        Write-Host "PowerShell v$rel installation cancelled."
        exit 0
    }
}

# install latest PowerShell version
Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI"
