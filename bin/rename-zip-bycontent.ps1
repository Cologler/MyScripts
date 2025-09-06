param(
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string[]] $Path
)

begin {
    function Get-CommonPrefix($strings) {
        if (-not $strings -or $strings.Count -eq 0) {
            return ""
        }

        if ($strings.Count -eq 1) {
            return $strings[0]
        }

        $sorted = $strings | Sort-Object
        $first  = $sorted[0]
        $last   = $sorted[-1]

        $i = 0
        while ($i -lt $first.Length -and $i -lt $last.Length -and $first[$i] -eq $last[$i]) {
            $i++
        }
        return $first.Substring(0, $i)
    }

    function Get-CommonSuffix($strings) {
        $reversed = $strings | ForEach-Object {
            $chars = $_.ToCharArray()
            [Array]::Reverse($chars);
            -join $chars
        }
        $revPrefix = Get-CommonPrefix $reversed
        return -join ($revPrefix | ForEach-Object {
            $chars = $_.ToCharArray()
            [Array]::Reverse($chars);
            -join $chars
        })
    }
}

process {
    foreach ($zipPath in $Path) {
        if (-not (Test-Path $zipPath)) { continue }

        try {
            $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
            $topNames = $zip.Entries |
                ForEach-Object {
                    $name = $_.FullName.Split('/')[0]
                    if ($name) { $name }
                } | Sort-Object -Unique
            $zip.Dispose()

            if ($topNames.Count -eq 0) { continue }

            $prefix = Get-CommonPrefix $topNames
            $suffix = Get-CommonSuffix $topNames
            $base   = ($prefix + $suffix)
            if ($base) {
                $base = ($base -replace '[\\/:*?"<>|]', '_')
                $newName = Join-Path (Split-Path $zipPath) ($base + ".zip")

                if ($newName -ne $zipPath) {
                    Rename-Item -LiteralPath $zipPath -NewName $newName
                    Write-Output "Renamed '$zipPath' -> '$newName'"
                }
            }
        }
        catch {
            Write-Warning "Failed to process $zipPath : $_"
        }
    }
}
