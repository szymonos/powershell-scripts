# PowerShell on Linux

## Preface

This is PowerShell on Linux configuration guide, to provide the streamlined and convenient experience to not only install and set up the PowerShell with optimized default settings and [oh-my-posh](https://ohmyposh.dev/) prompt theme, which is a cross-platform and cross shell, prompt theme engine.

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
├── install_pwsh.sh                 # installation script
└── PS_LINUX.md                     # this file
```

## Installation

All scripts are intended to be run from the repository root folder. To install and configure Linux on PowerShell, just run the command:

``` shell
.config/linux/install_pwsh.sh
```

If you have PowerLine/Nerd fonts installed, you can run the script with parameter `pl`, for the _nicer_ command prompt:

``` shell
.config/linux/install_pwsh.sh pl
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
