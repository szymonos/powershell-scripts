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
    [Alias('t')]
    [string]$OmpTheme,

    [Alias('m')]
    [string]$PSModules
)

# *Copy assets
# calculate variables
$profilePath = [IO.Path]::GetDirectoryName($PROFILE)
$scriptsPath = [IO.Path]::Combine($profilePath, 'Scripts')

# create profile path if not exist
if (-not (Test-Path $profilePath -PathType Container)) {
    New-Item $profilePath -ItemType Directory | Out-Null
}

# PowerShell profile
if ($OmpTheme) {
    $ompProfile = [IO.Path]::Combine($profilePath, 'theme.omp.json')
    if (Test-Path ".config/.assets/$OmpTheme" -PathType Leaf) {
        Copy-Item -Path ".config/.assets/$OmpTheme" -Destination $ompProfile -Force
    } else {
        [Net.WebClient]::new().DownloadFile("https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${OmpTheme}.omp.json", $ompProfile)
    }
    Copy-Item -Path .config/.assets/profile.ps1 -Destination $PROFILE.CurrentUserAllHosts -Force
} else {
    Copy-Item -Path .config/.assets/profile_win.ps1 -Destination $PROFILE.CurrentUserAllHosts -Force
}

# PowerShell functions
if (-not (Test-Path $scriptsPath -PathType Container)) {
    New-Item $scriptsPath -ItemType Directory | Out-Null
}
Copy-Item -Path .config/.assets/ps_aliases_common.ps1 -Destination $scriptsPath -Force
Copy-Item -Path .config/.assets/ps_aliases_win.ps1 -Destination $scriptsPath -Force
# git functions
if (Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue) {
    Copy-Item -Path .config/.assets/ps_aliases_git.ps1 -Destination $scriptsPath -Force
}
# kubectl functions
if (Get-Command kubectl.exe -CommandType Application -ErrorAction SilentlyContinue) {
    Copy-Item -Path .config/.assets/ps_aliases_kubectl.ps1 -Destination $scriptsPath -Force
    # add powershell kubectl autocompletion
    (kubectl.exe completion powershell).Replace("''kubectl''", "''k''") | Set-Content $PROFILE
}
# conda init
$condaSet = try { Select-String 'conda init' -Path $PROFILE.CurrentUserAllHosts -Quiet } catch { $false }
if ((Test-Path $HOME/miniconda3/Scripts/conda.exe) -and -not $condaSet) {
    Write-Host 'adding miniconda initialization...'
    & "$HOME/miniconda3/Scripts/conda.exe" init powershell | Out-Null
}

# *PowerShell profile
while (-not ((Get-Module PowerShellGet -ListAvailable).Version.Major -ge 3)) {
    Write-Host 'installing PowerShellGet...'
    Install-Module PowerShellGet -AllowPrerelease -Force
}
if (-not (Get-PSResourceRepository -Name PSGallery).Trusted) {
    Write-Host 'setting PSGallery trusted...'
    Set-PSResourceRepository -Name PSGallery -Trusted
}
while (-not (Get-Module posh-git -ListAvailable)) {
    Write-Host 'installing posh-git...'
    Install-PSResource -Name posh-git
}

# *PowerShell modules
# ps-modules modules
if ($PSModules) {
    if (-not (Test-Path '../ps-modules' -PathType Container)) {
        # clone ps-modules repository if not exists
        $remote = (git config --get remote.origin.url).Replace('powershell-scripts', 'ps-modules')
        git clone $remote ../ps-modules
    }
    $PSModules.Split() | ../ps-modules/module_manage.ps1 -CleanUp -Verbose
}

# installed modules
.include/manage_psmodules.ps1
