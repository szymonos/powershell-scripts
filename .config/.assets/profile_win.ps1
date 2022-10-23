#Requires -Version 7.2
#Requires -Modules PSReadLine

#region startup settings
# import posh-git module for git autocompletion.
if ($gitInstalled = [bool](Get-Command git -CommandType Application -ErrorAction SilentlyContinue)) {
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
Set-PSReadLineKeyHandler -Key Alt+Delete -Function DeleteLine
# set Startup Working Directory variable
$SWD = $PWD.Path
#endregion

#region functions
function Format-Duration ([timespan]$TimeSpan) {
    switch ($TimeSpan) {
        { $_.TotalMilliseconds -gt 0 -and $_.TotalMilliseconds -lt 10 } { '{0:N2}ms' -f $_.TotalMilliseconds }
        { $_.TotalMilliseconds -ge 10 -and $_.TotalMilliseconds -lt 100 } { '{0:N1}ms' -f $_.TotalMilliseconds }
        { $_.TotalMilliseconds -ge 100 -and $_.TotalMilliseconds -lt 1000 } { '{0:N0}ms' -f $_.TotalMilliseconds }
        { $_.TotalSeconds -ge 1 -and $_.TotalSeconds -lt 10 } { '{0:N3}s' -f $_.TotalSeconds }
        { $_.TotalSeconds -ge 10 -and $_.TotalSeconds -lt 100 } { '{0:N2}s' -f $_.TotalSeconds }
        { $_.TotalSeconds -ge 100 -and $_.TotalHours -le 1 } { $_.ToString('mm\:ss\.ff') }
        { $_.TotalHours -ge 1 -and $_.TotalDays -le 1 } { $_.ToString('hh\:mm\:ss') }
        { $_.TotalDays -ge 1 } { "$($_.Days * 24 + $_.Hours):$($_.ToString('mm\:ss'))" }
        Default { '0ms' }
    }
}
function Test-IsAdmin {
    [bool]$isAdmin = if ($IsWindows) {
            ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')
    } else {
            ((id -u) -eq 0) ? $true : $false
    }
    return $isAdmin
}
function cds { Set-Location $SWD }
#endregion

#region environment variables and aliases
if ($IsWindows) {
    $env:OS_EDITION = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption.Split(' ', 2)[1] + ' ' + `
        "($(Get-ItemPropertyValue 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name 'DisplayVersion'))"
    $env:SCRIPTS_PATH = [IO.Path]::Join([IO.Path]::GetDirectoryName($PROFILE.CurrentUserAllHosts), 'Scripts')
    $env:HOSTNAME = $env:COMPUTERNAME
} elseif ($IsLinux) {
    $env:OS_EDITION = (Select-String -Pattern '^PRETTY_NAME=(.*)' -Path /etc/os-release).Matches.Groups[1].Value.Trim("`"|'")
    $env:SCRIPTS_PATH = '/usr/local/share/powershell/Scripts'
    $env:COMPUTERNAME = $env:HOSTNAME
}
# aliases
(Get-ChildItem -Path $env:SCRIPTS_PATH -Filter 'ps_aliases_*.ps1' -File).ForEach{
    . $_.FullName
}
#endregion

#region PATH
@(
    [IO.Path]::Join($HOME, '.local', 'bin')
).ForEach{
    if ((Test-Path $_) -and $env:PATH -NotMatch "$($IsWindows ? "$($_.Replace('\', '\\'))\\" : "$_/")?($([IO.Path]::PathSeparator)|$)") {
        $env:PATH = [string]::Join([IO.Path]::PathSeparator, $_, $env:PATH)
    }
}
#endregion

#region prompt
function Prompt {
    # get execution time of the last command
    $executionTime = (Get-History).Count -gt 0 ? (Format-Duration(Get-History)[-1].Duration) : $null
    # get prompt path
    $promptPath = $PWD.Path.Replace($HOME, '~').Replace('Microsoft.PowerShell.Core\FileSystem::', '') -replace '\\$'
    $split = $promptPath.Split([IO.Path]::DirectorySeparatorChar)
    if ($split.Count -gt 3) {
        $promptPath = [IO.Path]::Join((($split[0] -eq '~') ? '~' : ($IsWindows ? "$($PWD.Drive.Name):" : $split[1])), '..', $split[-1])
    }
    # run elevated indicator
    if (Test-IsAdmin) {
        [Console]::Write("`e[91m#`e[0m ")
    }
    # write last execution time
    if ($executionTime) {
        [Console]::Write("[`e[93m$executionTime`e[0m] ")
    }
    # write prompt path
    [Console]::Write("`e[94m`u{e0b3}`u{e0b2}`e[0m`e[104;1m$promptPath`e[0m`e[94m`u{e0b0}`u{e0b1}`e[0m ")
    # write git branch/status
    if ($gitInstalled) {
        # get git status
        $gstatus = @(git status -b --porcelain=v2 2>$null)[1..4]
        if ($gstatus) {
            # get branch name and upstream status
            $branch = $gstatus[0].Split(' ')[2] + ($gstatus[1] -match 'branch.upstream' ? $null : " `u{21E1}")
            # format branch name color depending on working tree status
            [Console]::Write("{0}`u{E0A0} $branch ", ($gstatus | Select-String -Pattern '^(?!#)' -Quiet) ? "`e[38;2;255;146;72m" : "`e[38;2;212;170;252m")
        }
    }
    return "`e[92m$("`u{276d} " * ($nestedPromptLevel + 1))`e[0m"
}
#endregion

#region startup
Write-Host "$($PSStyle.Foreground.BrightWhite)$env:OS_EDITION | PowerShell $($PSVersionTable.PSVersion)$($PSStyle.Reset)"
#endregion
