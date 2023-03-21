<#
.SYNOPSIS
Install PowerShell Core using winget.
.EXAMPLE
.config/windows/scripts/install_pwsh.ps1
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
    } else {
        winget.exe upgrade --id Microsoft.PowerShell
    }
} else {
    winget.exe install --id Microsoft.PowerShell
}
