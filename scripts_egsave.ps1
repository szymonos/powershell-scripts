#Requires -PSEdition Core
#!/usr/bin/pwsh -nop
<#
.SYNOPSIS
Generate example scripts from the current repository.
.EXAMPLE
./scripts_egsave.ps1
#>

begin {
    $ErrorActionPreference = 'Stop'

    # set location to workspace folder
    Push-Location $PSScriptRoot

    # check if the Invoke-ExampleScriptSave function is available, otherwise clone ps-modules repo
    try {
        Get-Command Invoke-ExampleScriptSave -CommandType Function | Out-Null
    } catch {
        $targetRepo = 'ps-modules'
        # determine if target repository exists and clone if necessary
        $getOrigin = { git config --get remote.origin.url }
        $remote = (Invoke-Command $getOrigin) -replace '([:/]szymonos/)[\w-]+', "`$1$targetRepo"
        try {
            Push-Location "../$targetRepo"
            if ((Invoke-Command $getOrigin) -eq $remote) {
                # refresh target repository
                git fetch --prune --quiet
                git switch main --force --quiet
                git reset --hard --quiet 'origin/main'
            } else {
                Write-Warning "Another `"$targetRepo`" repository exists."
                exit 1
            }
            Pop-Location
        } catch {
            # clone target repository
            git clone $remote "../$targetRepo"
        }
        Import-Module -Name (Resolve-Path '../ps-modules/modules/do-common/do-common.psd1')
    }
}

process {
    # save example scripts
    $folders = @(
        'scripts/linux'
        'scripts/macos'
        'scripts/windows'
    )

    foreach ($folder in $folders) {
        Invoke-ExampleScriptSave $folder -FolderFromBase
    }
}

end {
    Pop-Location
}
