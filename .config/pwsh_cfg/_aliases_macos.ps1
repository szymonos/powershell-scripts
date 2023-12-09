# *Functions
function eza { & /usr/bin/env eza -g --color=auto --time-style=long-iso --group-directories-first --color-scale=all --git-repos @args }
function l { eza -1 @args }
function lsa { eza -a @args }
function ll { eza -lah @args }
function lt { eza -Th @args }
function lta { eza -aTh --git-ignore @args }
function ltd { eza -DTh @args }
function ltad { eza -aDTh --git-ignore @args }
function llt { eza -lTh @args }
function llta { eza -laTh --git-ignore @args }
function grep { $input | & /usr/bin/env grep --color=auto @args }
function less { $input | & /usr/bin/env less -FRXc @args }
function ls { & /usr/bin/env ls --color=auto @args }
function md { mkdir -p @args }
function mkdir { & /usr/bin/env mkdir -pv @args }
function mv { & /usr/bin/env mv -iv @args }
function p { & /usr/bin/env pwsh -NoProfileLoadTime @args }
function src { . $PROFILE.CurrentUserAllHosts }
function tree { & /usr/bin/env tree -C @args }

# *Aliases
Set-Alias -Name rd -Value rmdir
Set-Alias -Name vi -Value vim
