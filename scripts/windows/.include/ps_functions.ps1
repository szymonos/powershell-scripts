<#
.SYNOPSIS
Retry executing command if fails on HttpRequestException.
.PARAMETER Script
Script block of commands to execute.
#>
$ErrorActionPreference = 'Stop'

function Invoke-CommandRetry {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, HelpMessage = 'The command to be invoked.')]
        [scriptblock]$Command,

        [Parameter(HelpMessage = 'The number of retries the command should be invoked.')]
        [int]$MaxRetries = 10
    )

    $retryCount = 0
    do {
        try {
            Invoke-Command -ScriptBlock $Command @PSBoundParameters
            $exit = $true
        } catch [System.Net.Http.HttpRequestException] {
            if ($_.Exception.TargetSite.Name -eq 'MoveNext' -and $retryCount -lt $MaxRetries) {
                if ($_.ErrorDetails) {
                    Write-Verbose $_.ErrorDetails.Message
                } else {
                    Write-Verbose $_.Exception.Message
                }
                $retryCount++
                Write-Host 'Retrying...'
            } else {
                Write-Verbose $_.Exception.GetType().FullName
                Write-Error $_
            }
        } catch [System.AggregateException] {
            if ($_.Exception.InnerException.GetType().Name -eq 'HttpRequestException' -and $retryCount -lt $MaxRetries) {
                Write-Verbose $_.Exception.InnerException.Message
                $retryCount++
                Write-Host 'Retrying...'
            } else {
                Write-Verbose $_.Exception.InnerException.GetType().FullName
                Write-Error $_
            }
        } catch {
            Write-Verbose $_.Exception.GetType().FullName
            Write-Error $_
        }
    } until ($exit)
}

<#
.SYNOPSIS
Refresh path environment variable for process scope.
#>
function Update-SessionEnvironment {
    $auxHashSet = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)

    foreach ($scope in @('Machine', 'User', 'Process')) {
        [Environment]::GetEnvironmentVariable('Path', $scope).Split(';').Where({ $_ }) | ForEach-Object {
            $auxHashSet.Add($_) | Out-Null
        }
    }

    [Environment]::SetEnvironmentVariable('Path', [string]::Join(';', $auxHashSet), 'Process')
}

Set-Alias -Name refreshenv -Value Update-SessionEnvironment

<#
.SYNOPSIS
Check if current context is run as administrator.
#>
function Test-IsAdmin {
    $currentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [System.Security.Principal.WindowsPrincipal]$currentIdentity
    $admin = [System.Security.Principal.WindowsBuiltInRole]'Administrator'

    return $principal.IsInRole($admin)
}
