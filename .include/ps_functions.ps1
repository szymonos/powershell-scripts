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

function Join-String {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(ValueFromPipeline)]
        [string[]]${InputObject},

        [Parameter(Position = 0)]
        [string]$delim = ','
    )
    begin {
        $temp = [Collections.Generic.List[string]]::new()
    }
    process {
        $Item.ForEach({ $temp.Add($_) })
    }
    end {
        $temp -join $delim
    }
}

function Join-String {
    param(
        [string]$delim = ','
    )
    begin {
        $temp = [Collections.Generic.List[string]]::new()
    }
    process {
        $temp.Add($_)
    }
    end {
        $temp -join $delim
    }
}

function Invoke-RefreshPathEnvVariable {
    $envPath = @('Machine', 'User', 'Process') | `
    ForEach-Object { [Environment]::GetEnvironmentVariable('Path', $_).Split(';') } | `
    Select-Object -Unique | `
    Where-Object { $_ }

    [Environment]::SetEnvironmentVariable('Path', ([string]::Join(';', $envPath)), 'Process')
}
