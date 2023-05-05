# PowerShell Core on Windows

## Preface

This is PowerShell Core on Windows installation guide, to provide a streamlined and convenient experience to not only install and set up the PowerShell with optimized default settings and [oh-my-posh](https://ohmyposh.dev/) prompt theme, which is a cross-platform and cross shell, prompt theme engine.

Datetime formatting is set to respect **ISO-8601**, if you prefer other settings, you can remove the following line from the [profile.ps1](../../.config/pwsh_cfg/profile.ps1):

``` PowerShell
[Threading.Thread]::CurrentThread.CurrentCulture = 'en-SE'
```

## Installation

All scripts are intended to be run from the repository root folder. To install and configure PowerShell on Windows, just run the command:

``` PowerShell
scripts/windows/setup_powershell.ps1
```

If you have PowerLine/Nerd fonts installed, you can run the script with `-OmpTheme` parameter, for the _nicer_ command prompt. There are two additional pre-created profiles in the repository: `powerline` and `nerd`, using powerline and nerd fonts accordingly, but you can also specify any oh-my-posh theme from [Themes | Oh My Posh](https://ohmyposh.dev/docs/themes) and the [setup_omp.ps1](.include/setup_omp.ps1) script will automatically download it and install.

``` PowerShell
# using pre-created profiles
scripts/windows/setup_powershell.ps1 -OmpTheme 'powerline'
scripts/windows/setup_powershell.ps1 -OmpTheme 'nerd'
# examples of using oh-my-posh themes
scripts/windows/setup_powershell.ps1 -OmpTheme 'atomic'
scripts/windows/setup_powershell.ps1 -OmpTheme 'robbyrussell'
```

You can also specify to automatically install helper modules from [szymonos/ps-modules](https://github.com/szymonos/ps-modules) repository, or update existing modules in the process:

``` PowerShell
# set up PowerShell without oh-my-posh
scripts/windows/setup_powershell.ps1
scripts/windows/setup_powershell.ps1 -PSModules 'do-common do-win'
scripts/windows/setup_powershell.ps1 -PSModules 'do-common do-win' -UpdateModules
# set up PowerShell with oh-my-posh
scripts/windows/setup_powershell.ps1 -OmpTheme 'powerline'
scripts/windows/setup_powershell.ps1 -OmpTheme 'powerline' -PSModules 'do-common do-win'
scripts/windows/setup_powershell.ps1 -OmpTheme 'powerline' -PSModules 'do-common do-win' -UpdateModules
```

## Deinstallation

You can remove all the resources installed with the above commands, by running:

``` PowerShell
scripts/windows/clean_pwsh.ps1
```
