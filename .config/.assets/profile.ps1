#Requires -Version 7.2
#Requires -Modules PSReadLine

#region startup settings
# import posh-git module for git autocompletion.
if (Get-Command git -CommandType Application -ErrorAction SilentlyContinue) {
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
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key F2 -Function SwitchPredictionView
Set-PSReadLineKeyHandler -Key Shift+Tab -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Key Alt+j -Function NextHistory
Set-PSReadLineKeyHandler -Key Alt+k -Function PreviousHistory
Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
Set-PSReadLineKeyHandler -Key Ctrl+v -Function Paste
# set Startup Working Directory variable
$SWD = $PWD.Path
function cds { Set-Location $SWD }
#endregion

#region environment variables
if ($IsWindows) {
    $env:OS_EDITION = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption.Split(' ', 2)[1] + ' ' + `
        "($(Get-ItemPropertyValue 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name 'DisplayVersion'))"
    $env:OMP_PATH = [IO.Path]::GetDirectoryName($PROFILE.CurrentUserAllHosts)
    $env:SCRIPTS_PATH = [IO.Path]::Join($env:OMP_PATH, 'Scripts')
    $env:HOSTNAME = $env:COMPUTERNAME
} elseif ($IsLinux) {
    $env:OS_EDITION = (Select-String -Pattern '^PRETTY_NAME=(.*)' -Path /etc/os-release).Matches.Groups[1].Value.Trim("`"|'")
    $env:OMP_PATH = '/usr/local/share/oh-my-posh'
    $env:SCRIPTS_PATH = '/usr/local/share/powershell/Scripts'
    $env:COMPUTERNAME = $env:HOSTNAME
}
#endregion

# update Path environment variable
if ($IsLinux) {
    @("$HOME/.local/bin") | ForEach-Object {
        if ((Test-Path $_) -and $env:PATH -NotMatch $_) {
            $env:PATH = [string]::Join(':', $_, $env:PATH)
        }
    }
}

# source ps aliases
Get-ChildItem -Path $env:SCRIPTS_PATH -Filter 'ps_aliases_*.ps1' -File | ForEach-Object {
    . $_.FullName
}

# startup information
Write-Host "$($PSStyle.Foreground.BrightWhite)$env:OS_EDITION | PowerShell $($PSVersionTable.PSVersion)$($PSStyle.Reset)"

# initialize oh-my-posh prompt
if ((Get-Command oh-my-posh -ErrorAction SilentlyContinue) -and (Test-Path "$env:OMP_PATH/theme.omp.json")) {
    oh-my-posh --init --shell pwsh --config "$env:OMP_PATH/theme.omp.json" | Invoke-Expression
}
