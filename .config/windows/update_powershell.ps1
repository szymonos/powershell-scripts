#Requires -PSEdition Desktop
<#
.SYNOPSIS
Script synopsis.
.EXAMPLE
.config/windows/update_powershell.ps1
#>
. .include/ps_functions.ps1

# *Upgrade oh-my-posh
.config/windows/scripts/install_omp.ps1

# *Upgrade PowerShell
.config/windows/scripts/install_pwsh.ps1

# *Update modules
pwsh -NoProfile .include/manage_psmodules.ps1
