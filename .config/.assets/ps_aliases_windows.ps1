# *Functions
function Get-CommandSource {
    Invoke-Expression "(Get-Command $args -ErrorAction 'SilentlyContinue').Source"
}
function Get-DiskUsage {
    [CmdletBinding()]
    param (
        [Alias('p')]
        [Parameter(Position = 0, ValueFromPipeline)]
        [string]$Path = '.',

        [Alias('h')]
        [switch]$HumanReadable,

        [Alias('r')]
        [switch]$Recurse,

        [Alias('a')]
        [switch]$All,

        [Alias('s')]
        [ValidateSet('size', 'count', 'name')]
        [string]$Sort
    )

    begin {
        # filter for size formatting
        filter formatSize {
            switch ($_) {
                { $_ -ge 1KB -and $_ -lt 1MB } { '{0:0.0}K' -f ($_ / 1KB) }
                { $_ -ge 1MB -and $_ -lt 1GB } { '{0:0.0}M' -f ($_ / 1MB) }
                { $_ -ge 1GB -and $_ -lt 1TB } { '{0:0.0}G' -f ($_ / 1GB) }
                { $_ -ge 1TB } { '{0:0.0}T' -f ($_ / 1TB) }
                Default { "$_.0B" }
            }
        }

        # initialize empty collections
        $dirs = [Collections.Generic.List[PSObject]]::new()
        if ($Sort) {
            $result = [Collections.Generic.List[PSObject]]::new()
        }

        # IO enumeration options
        $enumDirs = [IO.EnumerationOptions]::new()
        $enumDirs.RecurseSubdirectories = $Recurse
        $enumFiles = [IO.EnumerationOptions]::new()
        $enumFiles.RecurseSubdirectories = !$Recurse
        # determine if to skip hidden and system objects
        $enumDirs.AttributesToSkip = $enumFiles.AttributesToSkip = ($All ? 0 : 6)
    }

    process {
        $startPath = Get-Item $Path
        $startPath.GetDirectories('*', $enumDirs).ForEach({ $dirs.Add($_) })
        if ($Recurse) {
            $dirs.Add($startPath)
        }
        foreach ($dir in $dirs) {
            $items = $dir.GetFiles('*', $enumFiles)
            $size = 0 + ($items | Measure-Object -Property Length -Sum).Sum
            $cnt = ($items | Measure-Object).Count
            $relPath = [IO.Path]::GetRelativePath($startPath.FullName, $dir.FullName)
            if ($Sort) {
                $result.Add([PSCustomObject]@{
                        Size  = $size
                        Count = $cnt
                        Name  = $relPath
                    })
            } else {
                if ($HumanReadable) {
                    $size = $size | formatSize
                    "$(' ' * (7 - $size.Length))$size   $(' ' * (8 - $cnt.ToString().Length))$cnt   $relPath"
                } else {
                    "$(' ' * (16 - $size.ToString().Length))$size   $(' ' * (8 - $cnt.ToString().Length))$cnt   $relPath"
                }
            }
        }

        if ($Sort) {
            $result | Sort-Object -Property $Sort | `
                Format-Table -HideTableHeaders @{Name = 'Size'; Expression = { $HumanReadable ? ($_.Size | formatSize) : ($_.Size) }; Align = 'Right' }, Count, Name
        }
    }
}

# *Aliases
Set-Alias -Name du -Value Get-DiskUsage
Set-Alias -Name sudo -Value gsudo
Set-Alias -Name which -Value Get-CommandSource
