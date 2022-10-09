# PowerShell Scripts

Repository for PowerShell scripts, modules, profiles, etc.

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

## PSReadLine

One of the best features for the PS CLI experience is the PSReadLine **List PredictionView**. Included profile turns it on by default, but also sets convenient shortcuts for navigation, so you don't have to take off your hand to reach the arrows:

- `Alt+j` - to select next element on the list
- `Alt+k` - to select the previous element on the list

### Other shortcuts

- `Tab` - expands menu completion, you can navigate it with arrows
- `F2` - switch between _List_*_ and _Inline_ prediction view
- `Shift+Tab` - accept inline suggestion
- `Ctrl+LeftArrow` - navigate word left
- `Ctrl+RightArrow` - navigate word right

## Links

- [PowerShell on Linux](.config/linux/PS_LINUX.md)
- [PowerShell on Window](.config/windows/PS_WINDOWS.md)
