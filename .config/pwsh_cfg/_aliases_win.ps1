# *Aliases
Set-Alias -Name _ -Value gsudo
Set-Alias -Name ff -Value fastfetch

# *eza functions
if (Get-Command eza.exe -CommandType Application -ErrorAction SilentlyContinue) {
    function exa { eza -g --color=auto --time-style=long-iso --group-directories-first --color-scale=all --git --icons --git-repos @args }
    function l { exa -1 @args }
    function lsa { exa -a @args }
    function ll { exa -lah @args }
    function lt { exa -Th @args }
    function lta { exa -aTh --git-ignore @args }
    function ltd { exa -DTh @args }
    function ltad { exa -aDTh --git-ignore @args }
    function llt { exa -lTh @args }
    function llta { exa -laTh --git-ignore @args }
} else {
    function ll { Get-ChildItem @args -Force }
}
