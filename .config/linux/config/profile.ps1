#Requires -Version 7.2
#Requires -Modules PSReadLine

#region startup settings
if (Get-Command git -CommandType Application -ErrorAction SilentlyContinue) {
    # import posh-git module for git autocompletion.
    Import-Module posh-git; $GitPromptSettings.EnablePromptStatus = $false
}
# make PowerShell console Unicode (UTF-8) aware
$OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()
# set culture to English Sweden for ISO-8601 datetime settings
[Threading.Thread]::CurrentThread.CurrentCulture = 'en-SE'
# Change PSStyle for directory coloring.
$PSStyle.FileInfo.Directory = "$($PSStyle.Bold)$($PSStyle.Foreground.Blue)"
# Configure PSReadLine setting.
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Chord F2 -Function SwitchPredictionView
Set-PSReadLineKeyHandler -Chord Shift+Tab -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Chord Alt+j -Function NextHistory
Set-PSReadLineKeyHandler -Chord Alt+k -Function PreviousHistory
# set Startup Working Directory variable
$SWD = $PWD.Path
function cds { Set-Location $SWD }
#endregion

#region environment variables
$env:OS_PRETTY_NAME = (Select-String -Pattern '^PRETTY_NAME=(.*)' -Path /etc/os-release).Matches.Groups[1].Value.Trim("`"|'")
$env:PROFILE_PATH = [IO.Path]::GetDirectoryName($PROFILE.AllUsersAllHosts)
$env:SCRIPTS_PATH = '/usr/local/share/powershell/Scripts'
$env:COMPUTERNAME = $env:HOSTNAME
#endregion

#region PATH
@("$HOME/.local/bin") | ForEach-Object {
    if ((Test-Path $_) -and $env:PATH -NotMatch $_) {
        $env:PATH = [string]::Join(':', $_, $env:PATH)
    }
}
#endregion

# source ps aliases
Get-ChildItem -Path $env:SCRIPTS_PATH -Filter 'ps_aliases_*.ps1' -File | ForEach-Object {
    . $_.FullName
}

# startup information
Write-Host "$($PSStyle.Foreground.BrightWhite)$env:OS_PRETTY_NAME | PowerShell $($PSVersionTable.PSVersion)$($PSStyle.Reset)"

# initialize oh-my-posh prompt
if ((Get-Command oh-my-posh -ErrorAction SilentlyContinue) -and (Test-Path '/etc/profile.d/theme.omp.json')) {
    oh-my-posh --init --shell pwsh --config /etc/profile.d/theme.omp.json | Invoke-Expression
}
