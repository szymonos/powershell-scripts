# *Functions
function grep { $input | & /usr/bin/env grep --color=auto @args }
function less { $input | & /usr/bin/env less -FRXc @args }
function ls { & /usr/bin/env ls --color=auto @args }
function l { ls -1 @args }
function lsa { ls -lah @args }
function ll { & /usr/bin/env exa -lagh --git --time-style=long-iso --group-directories-first @args }
function md { mkdir -p @args }
function mkdir { & /usr/bin/env mkdir -pv @args }
function mv { & /usr/bin/env mv -iv @args }
function p { & /usr/bin/env pwsh -NoProfileLoadTime @args }
function src { . $PROFILE.CurrentUserAllHosts }
function tree { & /usr/bin/env tree -C @args }

# *Aliases
Set-Alias -Name rd -Value rmdir
Set-Alias -Name vi -Value vim
