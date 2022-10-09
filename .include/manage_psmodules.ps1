#Requires -Version 7.0
<#
.SYNOPSIS
Script for updating PowerShell modules and cleaning-up old versions.
.EXAMPLE
.config/scripts/manage_psmodules.ps1       # *update and clean up modules
.config/scripts/manage_psmodules.ps1 -u    # *update modules only
.config/scripts/manage_psmodules.ps1 -c    # *clean up modules only
#>

param (
    [Alias('u')]
    [switch]$Update,

    [Alias('c')]
    [switch]$CleanUp
)

# check if the script is being run with elevated privileges
$isAdmin = if ($IsWindows) {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')
} else {
    ((id -u) -eq 0) ? $true : $false
}
# set update scope
if ($isAdmin) {
    $param = @{ Scope = 'AllUsers' }
} else {
    $param = @{ Scope = 'CurrentUser' }
}

if (-not $CleanUp) {
    Write-Host "$($PSStyle.Foreground.Yellow)updating modules in $($PSStyle.Underline)$($param.Scope)$($PSStyle.UnderlineOff) scope...$($PSStyle.Reset)"
    Update-PSResource @param -AcceptLicense
    Write-Host "$($PSStyle.Foreground.Yellow)checking pre-release versions...$($PSStyle.Reset)"
    $prerelease = Get-PSResource @param | Where-Object PrereleaseLabel
    foreach ($mod in $prerelease) {
        Write-Host "- $($mod.Name)"
        (Find-PSResource -Name $mod.Name -Prerelease) | ForEach-Object {
            if ($_.Version.ToString() -notmatch $mod.Version.ToString()) {
                Write-Host "$($PSStyle.Foreground.Green)found newer version: $($PSStyle.Bold)$($_.Version)$($PSStyle.Reset)"
                Update-PSResource @param -Name $mod.Name -Prerelease -AcceptLicense -Force
            }
        }
    }
}

if (-not $Update) {
    Write-Host "$($PSStyle.Foreground.Yellow)getting duplicate modules...$($PSStyle.Reset)"
    $dupedModules = Get-PSResource @param | Group-Object -Property Name | Where-Object Count -GT 1 | Select-Object -ExpandProperty Name

    foreach ($mod in $dupedModules) {
        $allVersions = Get-PSResource @param -Name $mod
        $latestVersion = ($allVersions | Sort-Object PublishedDate)[-1].Version

        Write-Host "`n$($PSStyle.Foreground.Cyan)$($PSStyle.Underline)$($mod)$($PSStyle.UnderlineOff) - $($allVersions.Count) versions of the module found, latest: $($PSStyle.Bold)v$latestVersion$($PSStyle.Reset)"
        Write-Host 'uninstalling...'
        foreach ($v in $allVersions.Where({ $_.Version -ne $latestVersion })) {
            Write-Host "- $($PSStyle.Foreground.BrightMagenta)v$($v.Version)$($PSStyle.Reset)"
            Uninstall-PSResource @param -Name $v.Name -Version ($v.Prerelease ? "$($v.Version)-$($v.Prerelease)" : "$($v.Version)") -SkipDependencyCheck
        }
    }
}

Write-Host "$($PSStyle.Foreground.BrightGreen)Done!$($PSStyle.Reset)"
