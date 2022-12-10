#Requires -Version 7.0
<#
.SYNOPSIS
Set up PowerShell profile on Windows.
.EXAMPLE
$OmpTheme = 'powerline'
$PSModules = 'do-common do-win'
.config/windows/scripts/setup_profile.ps1 $OmpTheme -m $PSModules
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory, Position = 0)]
    [ValidateSet('none', 'base', 'powerline')]
    [string]$OmpTheme,

    [Alias('m')]
    [string]$PSModules = $null
)

# *Copy assets
# calculate variables
$ompProfile = switch ($OmpTheme) {
    none {
        $null
    }
    base {
        '.config/.assets/theme.omp.json'
    }
    powerline {
        '.config/.assets/theme-pl.omp.json'
    }
}
$profilePath = [IO.Path]::GetDirectoryName($PROFILE)
$scriptsPath = [IO.Path]::Combine($profilePath, 'Scripts')

# create profile path if not exist
if (-not (Test-Path $profilePath -PathType Container)) {
    New-Item $profilePath -ItemType Directory | Out-Null
}

# PowerShell profile
if ($ompProfile) {
    Copy-Item -Path $ompProfile -Destination ([IO.Path]::Combine($profilePath, 'theme.omp.json'))
    Copy-Item -Path .config/.assets/profile.ps1 -Destination $PROFILE.CurrentUserAllHosts
} else {
    Copy-Item -Path .config/.assets/profile_win.ps1 -Destination $PROFILE.CurrentUserAllHosts
}

# PowerShell functions
if (-not (Test-Path $scriptsPath -PathType Container)) {
    New-Item $scriptsPath -ItemType Directory | Out-Null
}
Copy-Item -Path .config/.assets/ps_aliases_common.ps1 -Destination $scriptsPath
# git functions
if (Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue) {
    Copy-Item -Path .config/.assets/ps_aliases_git.ps1 -Destination $scriptsPath
}
# kubectl functions
if (Get-Command kubectl.exe -CommandType Application -ErrorAction SilentlyContinue) {
    Copy-Item -Path .config/.assets/ps_aliases_kubectl.ps1 -Destination $scriptsPath
    # add powershell kubectl autocompletion
    (kubectl.exe completion powershell).Replace("''kubectl''", "''k''") | Set-Content $PROFILE
}

# *PowerShell profile
while (-not ((Get-Module PowerShellGet -ListAvailable).Version.Major -ge 3)) {
    Write-Host 'installing PowerShellGet...'
    Install-Module PowerShellGet -AllowPrerelease -Scope AllUsers -Force
}
if (-not (Get-PSResourceRepository -Name PSGallery).Trusted) {
    Write-Host 'setting PSGallery trusted...'
    Set-PSResourceRepository -Name PSGallery -Trusted
}
while (-not (Get-Module posh-git -ListAvailable)) {
    Write-Host 'installing posh-git...'
    Install-PSResource -Name posh-git -Scope AllUsers
}

# *PowerShell modules
# ps-szymonos modules
if ($PSModules -and (Test-Path '../ps-szymonos/module_manage.ps1' -PathType Leaf)) {
    $PSModules.Split() | ../ps-szymonos/module_manage.ps1 -CleanUp -Verbose
}

# installed modules
.include/manage_psmodules.ps1
