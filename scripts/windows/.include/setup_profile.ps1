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
# :set up PowerShell without oh-my-posh
scripts/windows/.include/setup_profile.ps1
scripts/windows/.include/setup_profile.ps1 -m $PSModules
scripts/windows/.include/setup_profile.ps1 -m $PSModules -UpdateModules
# :set up PowerShell with oh-my-posh
$OmpTheme = 'nerd'
scripts/windows/.include/setup_profile.ps1 -t $OmpTheme
scripts/windows/.include/setup_profile.ps1 -t $OmpTheme -m $PSModules
scripts/windows/.include/setup_profile.ps1 -t $OmpTheme -m $PSModules -UpdateModules
#>
[CmdletBinding()]
param (
    [Alias('t')]
    [string]$OmpTheme,

    [Alias('m')]
    [ValidateScript({ $_.ForEach({ $_ -in @('aliases-git', 'aliases-kubectl', 'do-az', 'do-common', 'do-win') }) -notcontains $false },
        ErrorMessage = 'Wrong modules provided. Valid values: aliases-git aliases-kubectl do-az do-common do-win')]
    [string[]]$PSModules = @('do-common', 'do-win'),

    [switch]$UpdateModules
)

begin {
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
        scripts/windows/.include/install_omp.ps1
        scripts/windows/.include/setup_omp.ps1 $OmpTheme
        Copy-Item -Path .config/pwsh_cfg/profile.ps1 -Destination $PROFILE.CurrentUserAllHosts -Force
    } else {
        Copy-Item -Path .config/pwsh_cfg/profile_win.ps1 -Destination $PROFILE.CurrentUserAllHosts -Force
    }

    # *PowerShell functions
    Write-Host 'setting up profile...' -ForegroundColor Cyan
    # TODO to be removed, cleanup legacy aliases
    if (-not (Test-Path $scriptsPath)) {
        New-Item $scriptsPath -ItemType Directory | Out-Null
    }
    Get-ChildItem -Path $scriptsPath -Filter '*_aliases_*.ps1' -File | Remove-Item -Force
    if (-not (Test-Path $scriptsPath -PathType Container)) {
        New-Item $scriptsPath -ItemType Directory | Out-Null
    }
    Write-Host 'copying aliases' -ForegroundColor DarkGreen
    Copy-Item -Path .config/pwsh_cfg/_aliases_common.ps1 -Destination $scriptsPath -Force
    Copy-Item -Path .config/pwsh_cfg/_aliases_win.ps1 -Destination $scriptsPath -Force

    # *conda init
    if ((Test-Path $HOME/miniconda3/Scripts/conda.exe) -and -not (Select-String 'conda init' -Path $PROFILE.CurrentUserAllHosts -Quiet)) {
        Write-Verbose 'adding miniconda initialization...'
        & "$HOME/miniconda3/Scripts/conda.exe" init powershell | Out-Null
    }

    # *install modules
    # TODO to be removed, uninstall PowerShellGet v3
    if ($psGetv3 = (Get-Module PowerShellGet -ListAvailable).Where({ $_.Version.Major -eq 3 })) {
        $psGetv3 | Uninstall-Module
    }
    # install Microsoft.PowerShell.PSResourceGet
    for ($i = 0; -not (Get-Module Microsoft.PowerShell.PSResourceGet -ListAvailable) -and $i -lt 5; $i++) {
        Write-Host 'installing PSResourceGet...'
        Install-Module Microsoft.PowerShell.PSResourceGet -AllowPrerelease -Scope AllUsers -Force -SkipPublisherCheck
    }
    # install/update modules
    if (Get-InstalledModule -Name Microsoft.PowerShell.PSResourceGet) {
        if (-not (Get-PSResourceRepository -Name PSGallery).Trusted) {
            Write-Host 'setting PSGallery trusted...'
            Set-PSResourceRepository -Name PSGallery -Trusted -ApiVersion v2
        }
        for ($i = 0; (Test-Path /usr/bin/git) -and -not (Get-Module posh-git -ListAvailable) -and $i -lt 5; $i++) {
            Write-Host 'installing posh-git...'
            Install-PSResource -Name posh-git
        }
        # update existing modules
        if (Test-Path scripts/windows/.include/update_psresources.ps1 -PathType Leaf) {
            scripts/windows/.include/update_psresources.ps1
        }
    }

    # *ps-modules
    $modules = [Collections.Generic.HashSet[String]]::new()
    $PSModules.ForEach({ $modules.Add($_) | Out-Null })

    # determine modules to install
    if (Get-Module -ListAvailable Az) {
        $modules.Add('do-az') | Out-Null
        Write-Verbose "Added `e[3mdo-az`e[23m to be installed from ps-modules."
    }
    if (Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue) {
        $modules.Add('aliases-git') | Out-Null
        Write-Verbose "Added `e[3maliases-git`e[23m to be installed from ps-modules."
    }
    if (Get-Command kubectl.exe -CommandType Application -ErrorAction SilentlyContinue) {
        $modules.Add('aliases-kubectl') | Out-Null
        Write-Verbose "Added `e[3maliases-kubectl`e[23m to be installed from ps-modules."
        # set powershell kubectl autocompletion
        [IO.File]::WriteAllText($PROFILE, (kubectl.exe completion powershell).Replace("''kubectl''", "''k''"))
    }

    if ($modules) {
        $targetRepo = 'ps-modules'
        # determine if target repository exists and clone if necessary
        $getOrigin = { git config --get remote.origin.url }
        $remote = (Invoke-Command $getOrigin) -replace '([:/]szymonos/)[\w-]+', "`$1$targetRepo"
        try {
            Push-Location "../$targetRepo"
            if ((Invoke-Command $getOrigin) -eq $remote) {
                # refresh target repository
                git fetch --prune --quiet
                git switch main --force --quiet 2>$null
                git reset --hard --quiet 'origin/main'
            } else {
                Write-Warning "Another `"$targetRepo`" repository exists."
                $modules = [System.Collections.Generic.HashSet[string]]::new()
            }
            Pop-Location
        } catch {
            # clone target repository
            git clone $remote "../$targetRepo"
        }
        if ($modules) {
            Write-Host 'installing ps-modules...' -ForegroundColor Cyan
            Write-Host "`e[3mCurrentUser`e[23m : $modules" -ForegroundColor DarkGreen
            $modules | & "../$targetRepo/module_manage.ps1" -CleanUp -ErrorAction SilentlyContinue
        }
    }
}

end {
    Pop-Location
}
