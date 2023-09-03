#Requires -RunAsAdministrator
#Requires -PSEdition Desktop
<#
.SYNOPSIS
Install PowerShell Core.
.EXAMPLE
scripts/windows/.include/install_pwsh.ps1
#>
$ErrorActionPreference = 'Stop'

if ($pwshProcess = Get-Process pwsh -ErrorAction SilentlyContinue) {
    $msg = 'Do you want to terminate existing pwsh process(es)? [y/N]'
    if ((Read-Host -Prompt $msg) -eq 'y') {
        $pwshProcess | Stop-Process -Force
    } else {
        Write-Host "PowerShell v$rel installation cancelled."
        exit 0
    }
}

# install latest PowerShell version
Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI"
