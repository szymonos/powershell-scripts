# PowerShell on Linux

## Preface

This is PowerShell on Linux configuration guide, to provide the streamlined and convenient experience to not only install and set up the PowerShell with optimized default settings and [oh-my-posh](https://ohmyposh.dev/) prompt theme, which is a cross-platform and cross shell, prompt theme engine.

Profile, theme, and aliases/functions are being installed globally, so the configuration is preserved also when running as sudo.

Datetime formatting is set to respect **ISO-8601**, if you prefer other settings, you can remove the following line from the [profile.ps1](.config/linux/config/profile.ps1):

``` powershell
[Threading.Thread]::CurrentThread.CurrentCulture = 'en-SE'
```

and remove `--time-style=long-iso` parameter from **ls** aliases/functions in the [ps_aliases_common.ps1](.config/linux/config/ps_aliases_common.ps1) file.

## Folder structure

``` sh
.
├── config                          # folder with profile, themes, aliases/functions
│   ├── profile.ps1                   # PowerShell profile
│   ├── ps_aliases_common.ps1         # common aliases/functions
│   ├── ps_aliases_git.ps1            # git aliases/functions
│   ├── ps_aliases_kubectl.ps1        # kubectl aliases/functions
│   ├── theme.omp.json                # oh-my-posh prompt theme using standard fonts
│   └── theme-pl.omp.json             # oh-my-posh prompt theme using PowerLine fonts
├── scripts                         # installation/configuration scripts
│   ├── install_omp.sh                # oh-my-posh installation script
│   ├── install_pwsh.sh               # PowerShell installation script
│   └── setup_profile_allusers.sh     # configuration script
├── clean_pwsh.sh                   # cleanup script, that removes PowerShell and all installed files
├── setup_powershell.sh             # PowerShell installation and configuration script
└── PS_LINUX.md                     # this file
```

## Installation

All scripts are intended to be run from the repository root folder. To install and configure Linux on PowerShell, just run the command:

``` shell
.config/linux/setup_powershell.sh
```

If you have PowerLine/Nerd fonts installed, you can run the script with parameter `pl`, for the _nicer_ command prompt:

``` shell
.config/linux/setup_powershell.sh pl
```

## Deinstallation

You can remove all the resources installed with the above commands, by running:

``` shell
.config/linux/clean_pwsh.sh
```

## Hints

One of the best features for the PS CLI experience is the PSReadLine **List PredictionView**. Included profile turns it on by default, but also sets convenient shortcuts for navigation, so you don't have to take off your hand to reach the arrows:

- `Alt+j` - to select next element on the list
- `Alt+k` - to select the previous element on the list

### Other shortcuts

- `Tab` - expands menu completion, you can navigate it with arrows
- `F2` - switch between _List_*_ and _Inline_ prediction view
- `Shift+Tab` - accept inline suggestion

## Caveats

- **PSNativeCommandArgumentPassing** - this is an experimental feature enabled during the installation for both, root, and user profiles. It is essential to have turned it on, otherwise, string parsing in PowerShell would be _"broken"_ and work differently than in bash. You can read more [here](https://learn.microsoft.com/en-us/powershell/scripting/learn/experimental-features?view=powershell-7.2#psnativecommandargumentpassing).

- **Aliases/Functions** - PowerShell treats aliases differently than bash - you cannot alias command with additional parameters - for this you need to create a function. It breaks autocompletion, so all _aliases_ defined in the function are not aware of the possible arguments. Another _issue_ is that you cannot create a function named the same as the _aliased_ command, for that you need to use env command like this:
`function mv { & /usr/bin/env mv -iv $args }`.

- **Invoke-Sudo** - this is a function, defined in [ps_aliases_common.ps1](.config/linux/config/ps_aliases_common.ps1), to run a command as sudo (aliased as sudo). The function has been created to prevent existing aliases, and functions when running commands as sudo in PowerShell. It does work for oneliner functions and all aliases, but breaks when you pass quoted parameters with spaces, so e.g. command `sudo ls './one two/'` won't work.

- **PowerShell Logo** - by default, when you run `pwsh` command, it prints _annoying_ logo. It is supposed to be changed in PowerShell v7.3, but as of now I recommend creating an alias `alias pwsh='pwsh -NoLogo'` in bash profile, to prevent it, when starting PowerShell.
