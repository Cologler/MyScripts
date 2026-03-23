[CmdletBinding()]
param ()

& {
    Import-Module (Join-Path $PSScriptRoot '..' 'lib' 'uv.psm1') -Scope Local -DisableNameChecking

    $uvToolDir = Get-UvToolDir

    $tools = @{}

    Get-ChildItem -Path $uvToolDir -Directory | ForEach-Object {
        $toolName = $_.Name
        $receiptPath = Join-Path $uvToolDir $toolName 'uv-receipt.toml'
        if (-not (Test-Path $receiptPath)) {
            return
        }

        $receiptText = Get-Content -Raw $receiptPath
        $receipt = $receiptText | ConvertFrom-Toml

        # entrypoints are not needed in export.
        if ($null -ne $receipt.tool) {
            if ($receipt.tool -is [System.Collections.IDictionary]) {
                # e.g. OrderedDictionary
                [void]$receipt.tool.Remove('entrypoints')
            }
        }

        # Key: tool name, Value: parsed uv-receipt.toml
        $tools[$toolName] = $receipt
    }

    # Keyed by tool name; value is parsed uv-receipt.toml ("receipt").
    # The tool-export output no longer wraps everything in an extra layer
    # (e.g., Tools/Receipt).
    $export = $tools

    # Depth needs to be high because uv receipt contains nested tables/arrays.
    Write-Output ($export | ConvertTo-Json -Depth 100)
}

