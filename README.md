# PowerShell Scripts

Repository for PowerShell setup scripts for Windows, Linux and macOS.

## Folder structure

``` sh
.
├── .config           # configuration files
│   ├── omp_cfg         # oh-my-posh themes
│   └── pwsh_cfg        # PowerShell profiles and aliases/functions
├── .vscode           # VSCode configuration
└── scripts           # helper scripts and functions for running other scripts
│   ├── linux           # Linux setup scripts
│   │   └── .include      # installation scripts
│   ├── macos           # macOS setup scripts
│   │   └── .include      # installation scripts
│   └── windows         # Windows setup scripts
│       └── .include      # installation scripts
```

## PSReadLine

One of the best features for the PS CLI experience is the PSReadLine **List PredictionView**. Included profile turns it on by default, but also sets convenient shortcuts for navigation, so you don't have to take off your hand to reach the arrows:

- `Alt+j` - to select next element on the list
- `Alt+k` - to select the previous element on the list

> Doesn't work on macOS 😞.

### Other shortcuts

- `Tab` - expands menu completion, you can navigate it with arrows
- `F2` - switch between _List_*_ and _Inline_ prediction view
- `Shift+Tab` - accept inline suggestion
- `Ctrl+LeftArrow` - navigate word left
- `Ctrl+RightArrow` - navigate word right
- `Alt+Delete` - delete whole command line

## Links

- [PowerShell on Linux](scripts/linux/PS_LINUX.md)
- [PowerShell on Windows](scripts/windows/PS_WINDOWS.md)
- [PowerShell on macOS](scripts/macos/PS_MACOS.md)
