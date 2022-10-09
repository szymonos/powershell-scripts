# *Functions
function grep { $input | & /usr/bin/env grep --color=auto $args }
function less { $input | & /usr/bin/env less -FSRXc $args }
function ls { & /usr/bin/env ls --color=auto --group-directories-first $args }
function ll { & /usr/bin/env ls -lAh --color=auto --time-style=long-iso --group-directories-first $args }
function l { & /usr/bin/env ls -1 --color=auto --group-directories-first $args }
function lsa { & /usr/bin/env ls -lah --color=auto --time-style=long-iso --group-directories-first $args }
function md { mkdir -p $args }
function mkdir { & /usr/bin/env mkdir -pv $args }
function mv { & /usr/bin/env mv -iv $args }
function nano { & /usr/bin/env nano -W $args }
function pwsh { & /usr/bin/env pwsh -nol $args }
function p { & /usr/bin/env pwsh -nol $args }
function src { . $PROFILE.CurrentUserAllHosts }
function wget { & /usr/bin/env wget -c $args }
function Invoke-SudoPS {
    # determine if the first argument is an alias or function
    if ($cmd = (Get-Command $args[0] -CommandType Alias, Function -ErrorAction SilentlyContinue).Definition.Where({ $_ -notmatch '\n' })) {
        $args[0] = $cmd.Trim().Replace('$input | ', '').Replace('& /usr/bin/env ', '').Replace(' $args', '')
    }
    # parse sudo parameters and command with arguments
    $params = ("$args" | Select-String '^-.+?(?=\s+[^-])').Matches.Value
    $cmd = ("$args" -replace $params).Trim()
    # run sudo command with resolved commands
    & /usr/bin/env sudo $params pwsh -NoProfile -NonInteractive -Command "$cmd"
}
function Invoke-Sudo {
    # determine if the first argument is an alias or function
    if ($cmd = (Get-Command $args[0] -CommandType Alias, Function -ErrorAction SilentlyContinue).Definition.Where({ $_ -notmatch '\n' })) {
        $args[0] = $cmd.Trim().Replace('$input | ', '').Replace('& /usr/bin/env ', '').Replace(' $args', '')
    }
    # parse sudo parameters and command with arguments
    $params = ("$args" | Select-String '^-.+?(?=\s+[^-])').Matches.Value
    $cmd = ("$args" -replace $params).Trim()
    # run sudo command with resolved commands
    & /usr/bin/env sudo $params bash -c "$cmd"
}

# *Aliases
Set-Alias -Name _ -Value Invoke-SudoPS
Set-Alias -Name rd -Value rmdir
Set-Alias -Name sudo -Value Invoke-Sudo
Set-Alias -Name vi -Value vim