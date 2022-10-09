$ErrorActionPreference = 'Stop'

<#
.SYNOPSIS
Retry executing command if fails on HttpRequestException.
.PARAMETER Script
Script block of commands to execute.
#>
function Invoke-CommandRetry {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [scriptblock]$Script
    )
    do {
        try {
            Invoke-Command -ScriptBlock $Script
            $exit = $true
        } catch [System.Net.Http.HttpRequestException] {
            if ($_.ErrorDetails) {
                Write-Verbose $_.ErrorDetails.Message
            } else {
                Write-Verbose $_.Exception.Message
            }
            Write-Host 'Retrying...'
        } catch [System.AggregateException] {
            if ($_.Exception.InnerException.GetType().Name -eq 'HttpRequestException') {
                Write-Verbose $_.Exception.InnerException.Message
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
Check if PowerShell runs elevated.
#>
function Test-IsAdmin {
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    process {
        $isAdmin = if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
            ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
        } else {
            if ((id -u) -eq 0) { $true } else { $false }
        }
    }

    end {
        return $isAdmin
    }
}

if ($PSVersionTable.PSEdition -eq 'Desktop') {
    function Join-String {
        <#
        .SYNOPSIS
        Join strings from pipeline.
        #>
        [CmdletBinding()]
        [OutputType([string])]
        param (
            [Parameter(Mandatory, ValueFromPipeline)]
            [string[]]${InputObject},

            [Parameter(Position = 0)]
            [ValidateNotNullorEmpty()]
            [string]$Separator = ','
        )
        begin {
            $temp = [Collections.Generic.List[string]]::new()
        }
        process {
            $InputObject.ForEach({ $temp.Add($_) })
        }
        end {
            $temp -join $Separator
        }
    }
}

<#
.SYNOPSIS
Refresh path environment variable for process scope.
#>
function Update-SessionEnvironment {
    $envPath = @('Machine', 'User', 'Process') | `
        ForEach-Object { [Environment]::GetEnvironmentVariable('Path', $_).Split(';') } | `
        Select-Object -Unique | `
        Where-Object { $_ } | `
        Join-String -Separator ';'

    [Environment]::SetEnvironmentVariable('Path', $envPath, 'Process')
}

Set-Alias -Name refreshenv -Value Update-SessionEnvironment
