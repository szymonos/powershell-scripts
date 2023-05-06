# PowerShell on Linux

## Preface

This is PowerShell on Linux configuration guide, to provide a streamlined and convenient experience to not only install and set up the PowerShell with optimized default settings and [oh-my-posh](https://ohmyposh.dev/) prompt theme, which is a cross-platform and cross shell, prompt theme engine.

Profile, theme, and aliases/functions are being installed globally, so the configuration is preserved also when running as sudo.

Datetime formatting is set to respect **ISO-8601**, if you prefer other settings, you can remove the following line from the [profile.ps1](../../.config/pwsh_cfg/profile.ps1):

``` PowerShell
[Threading.Thread]::CurrentThread.CurrentCulture = 'en-SE'
```

and remove `--time-style=long-iso` parameter from **ls** aliases/functions in the [_aliases_common.ps1](../../.config/pwsh_cfg/_aliases_linux.ps1) file.

## Installation

All scripts are intended to be run from the repository root folder. To install and configure PowerShell on Linux, just run the command:

``` sh
scripts/linux/setup_powershell.sh
```

If you have PowerLine/Nerd fonts installed, you can run the script with `--theme` parameter, for the _nicer_ command prompt. There are two additional pre-created profiles in the repository: `powerline` and `nerd`, using powerline and nerd fonts accordingly, but you can also specify any oh-my-posh theme from [Themes | Oh My Posh](https://ohmyposh.dev/docs/themes) and the [setup_omp.sh](.include/setup_omp.sh) script will automatically download it and install.

``` sh
# using pre-created profiles
scripts/linux/setup_powershell.sh --theme 'powerline'
scripts/linux/setup_powershell.sh --theme 'nerd'
# examples of using oh-my-posh themes
scripts/linux/setup_powershell.sh --theme 'atomic'
scripts/linux/setup_powershell.sh --theme 'robbyrussell'
```

## Deinstallation

You can remove all the resources installed with the above commands, by running:

``` sh
scripts/linux/clean_pwsh.sh
```

## Update

You can update `oh-my-posh`, `PowerShell`, and its modules, by running:

``` sh
scripts/linux/update_powershell.sh
```

## Caveats

- **Aliases/Functions** - PowerShell treats aliases differently than bash - you cannot alias command with additional parameters - for this you need to create a function. It breaks autocompletion, so all _aliases_ defined in the function are not aware of the possible arguments. Another _issue_ is that you cannot create a function named the same as the _aliased_ command, for that you need to use env command like this:

   ``` PowerShell
   function ip { $input | & /usr/bin/env ip --color=auto @args }
   ```
