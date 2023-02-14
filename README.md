# PowerShell Scripts

Repository for PowerShell scripts, modules, profiles, etc.

## Folder structure

``` sh
.
├── .config           # configuration setup scripts and files
│   ├── .assets         # folder with profile, themes, aliases/functions
│   │   ├── omp_cfg       # oh-my-posh themes
│   │   └── pwsh_cfg      # PowerShell profiles and aliases/functions
│   ├── linux           # Linux setup scripts
│   │   └── scripts       # installation scripts
│   ├── macos           # macOS setup scripts
│   │   └── scripts       # installation scripts
│   └── windows         # Windows setup scripts
│       └── scripts       # installation scripts
├── .include          # helper scripts and functions for running other scripts
└── .vscode           # VSCode configuration
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
- `Alt+Delete` - delete whole command line

## Links

- [PowerShell on Linux](.config/linux/PS_LINUX.md)
- [PowerShell on Window](.config/windows/PS_WINDOWS.md)
