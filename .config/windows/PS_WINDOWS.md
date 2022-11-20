# PowerShell on Linux

## Preface

This is PowerShell Core on Windows configuration guide, to provide a streamlined and convenient experience to not only install and set up the PowerShell with optimized default settings and [oh-my-posh](https://ohmyposh.dev/) prompt theme, which is a cross-platform and cross shell, prompt theme engine.

## Installation

All scripts are intended to be run from the repository root folder. To install and configure Linux on PowerShell, just run the command:

``` PowerShell
.config/windows/setup_powershell.ps1
```

If you have PowerLine/Nerd fonts installed, you can run the script with parameter `pl`, for the _nicer_ command prompt:

``` PowerShell
.config/windows/setup_powershell.ps1 pl
```

## Deinstallation

You can remove all the resources installed with the above commands, by running:

``` PowerShell
.config/windows/clean_pwsh.ps1
```

## Update

You can update `oh-my-posh`, `PowerShell`, and its modules, by running:

``` PowerShell
.config/windows/update_powershell.ps1
```
