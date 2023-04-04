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
$PSModules = @('do-common', 'do-win')
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
    [string[]]$PSModules,

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
        Write-Host 'installing omp...' -ForegroundColor Cyan
        .config/windows/scripts/install_omp.ps1
        .config/windows/scripts/setup_omp.ps1 $OmpTheme
        Copy-Item -Path .config/.assets/pwsh_cfg/profile.ps1 -Destination $PROFILE.CurrentUserAllHosts -Force
    } else {
        Copy-Item -Path .config/.assets/pwsh_cfg/profile_win.ps1 -Destination $PROFILE.CurrentUserAllHosts -Force
    }

    # *PowerShell functions
    Write-Host 'setting up profile...' -ForegroundColor Cyan
    # TODO to be removed, cleanup legacy aliases
    Get-ChildItem -Path $scriptsPath -Filter '*_aliases_*.ps1' -File | Remove-Item -Force
    if (-not (Test-Path $scriptsPath -PathType Container)) {
        New-Item $scriptsPath -ItemType Directory | Out-Null
    }
    Write-Host 'copying aliases...' -ForegroundColor DarkGreen
    Copy-Item -Path .config/.assets/pwsh_cfg/_aliases_common.ps1 -Destination $scriptsPath -Force
    Copy-Item -Path .config/.assets/pwsh_cfg/_aliases_win.ps1 -Destination $scriptsPath -Force

    # *conda init
    $condaSet = try { Select-String 'conda init' -Path $PROFILE.CurrentUserAllHosts -Quiet } catch { $false }
    if ((Test-Path $HOME/miniconda3/Scripts/conda.exe) -and -not $condaSet) {
        Write-Verbose 'adding miniconda initialization...'
        & "$HOME/miniconda3/Scripts/conda.exe" init powershell | Out-Null
    }

    # *update installed modules
    if ($UpdateModules) {
        .config/windows/scripts/update_psresources.ps1
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
    $moduleList = [Collections.Generic.List[string]]::new()
    $PSModules.ForEach({ $moduleList.Add($_) })
    if (Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue) {
        $moduleList.Add('aliases-git')
    }
    if (Get-Command kubectl.exe -CommandType Application -ErrorAction SilentlyContinue) {
        $moduleList.Add('aliases-kubectl')
        # set powershell kubectl autocompletion
        [IO.File]::WriteAllText($PROFILE, (kubectl.exe completion powershell).Replace("''kubectl''", "''k''"))
    }
    if ($moduleList) {
        Write-Host 'installing ps-modules...' -ForegroundColor Cyan
        # determine if ps-modules repository exist and clone if necessary
        $getOrigin = { git config --get remote.origin.url }
        $remote = (Invoke-Command $getOrigin).Replace('powershell-scripts', 'ps-modules')
        try {
            Push-Location '../ps-modules'
            if ($(Invoke-Command $getOrigin) -eq $remote) {
                # pull ps-modules repository
                git reset --hard --quiet && git clean --force -d && git pull --quiet
            } else {
                $moduleList = [Collections.Generic.List[string]]::new()
            }
            Pop-Location
        } catch {
            # clone ps-modules repository
            git clone $remote ../ps-modules
        }
        $moduleList | ../ps-modules/module_manage.ps1 -CleanUp -Verbose -ErrorAction SilentlyContinue
    }
}

end {
    Pop-Location
}
