#Requires -Version 7.0
<#
.SYNOPSIS
Set up PowerShell Core profile on Windows.

.PARAMETER OmpTheme
Specify oh-my-posh theme to be installed, from themes available on the page.
There are also two baseline profiles included: base and powerline.
.PARAMETER PSModules
List of PowerShell modules from ps-modules repository to be installed.
.PARAMETER UpdateModules
Switch, whether to update installed PowerShell modules.

.EXAMPLE
$PSModules = 'do-common do-win'
# ~set up PowerShell without oh-my-posh
.config/windows/scripts/setup_profile.ps1
.config/windows/scripts/setup_profile.ps1 -m $PSModules
.config/windows/scripts/setup_profile.ps1 -m $PSModules -UpdateModules
# ~set up PowerShell with oh-my-posh
$OmpTheme = 'powerline'
.config/windows/scripts/setup_profile.ps1 -t $OmpTheme
.config/windows/scripts/setup_profile.ps1 -t $OmpTheme -m $PSModules
.config/windows/scripts/setup_profile.ps1 -t $OmpTheme -m $PSModules -UpdateModules
#>
[CmdletBinding()]
param (
    [Alias('t')]
    [string]$OmpTheme,

    [Alias('m')]
    [string]$PSModules,

    [switch]$UpdateModules
)

begin {
    $ErrorActionPreference = 'Stop'

    # calculate variables
    $profilePath = [IO.Path]::GetDirectoryName($PROFILE)
    $scriptsPath = [IO.Path]::Combine($profilePath, 'Scripts')

    # create profile path if not exist
    if (-not (Test-Path $profilePath -PathType Container)) {
        New-Item $profilePath -ItemType Directory | Out-Null
    }

    # set location to workspace folder
    Push-Location "$PSScriptRoot/../../.."

}

process {
    # *PowerShell profile
    if ($OmpTheme) {
        .config/windows/scripts/install_omp.ps1
        .config/windows/scripts/setup_omp.ps1 $OmpTheme
        Copy-Item -Path .config/.assets/pwsh_cfg/profile.ps1 -Destination $PROFILE.CurrentUserAllHosts -Force
    } else {
        Copy-Item -Path .config/.assets/pwsh_cfg/profile_win.ps1 -Destination $PROFILE.CurrentUserAllHosts -Force
    }

    # *PowerShell functions
    if (-not (Test-Path $scriptsPath -PathType Container)) {
        New-Item $scriptsPath -ItemType Directory | Out-Null
    }
    Copy-Item -Path .config/.assets/pwsh_cfg/ps_aliases_common.ps1 -Destination $scriptsPath -Force
    Copy-Item -Path .config/.assets/pwsh_cfg/ps_aliases_win.ps1 -Destination $scriptsPath -Force
    # git functions
    if (Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue) {
        Copy-Item -Path .config/.assets/pwsh_cfg/ps_aliases_git.ps1 -Destination $scriptsPath -Force
    }
    # kubectl functions
    if (Get-Command kubectl.exe -CommandType Application -ErrorAction SilentlyContinue) {
        Copy-Item -Path .config/.assets/pwsh_cfg/ps_aliases_kubectl.ps1 -Destination $scriptsPath -Force
        # add powershell kubectl autocompletion
    (kubectl.exe completion powershell).Replace("''kubectl''", "''k''") | Set-Content $PROFILE
    }

    # *conda init
    $condaSet = try { Select-String 'conda init' -Path $PROFILE.CurrentUserAllHosts -Quiet } catch { $false }
    if ((Test-Path $HOME/miniconda3/Scripts/conda.exe) -and -not $condaSet) {
        Write-Host 'adding miniconda initialization...'
        & "$HOME/miniconda3/Scripts/conda.exe" init powershell | Out-Null
    }

    # *update installed modules
    if ($UpdateModules) {
        .include/manage_psmodules.ps1
    }

    # *install modules
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

    # *ps-modules
    if ($PSModules) {
        if (-not (Test-Path '../ps-modules' -PathType Container)) {
            # clone ps-modules repository if not exists
            $remote = (git config --get remote.origin.url).Replace('powershell-scripts', 'ps-modules')
            git clone $remote ../ps-modules
        }
        $PSModules.Split() | ../ps-modules/module_manage.ps1 -CleanUp -Verbose
    }
}

end {
    Pop-Location
}
