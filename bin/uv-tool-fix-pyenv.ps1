[CmdletBinding()]
param ()

& {
    Import-Module (Join-Path $PSScriptRoot '..' 'lib' 'uv.psm1') -Scope Local

    $uvToolDir = Get-UvToolDir

    uv tool list --show-with --show-extras | ForEach-Object {
        if ($_ -match '^-') {
            # execute program name
            return
        }

        $toolInfo = Parse-UvToolList $_
        if ($toolInfo) {
            $cfgPath  = Join-Path $uvToolDir $toolInfo.tool 'pyvenv.cfg'
            $cfgContent = Parse-PyvenvCfg -cfgPath $cfgPath

            if (-not (Test-Path $cfgContent.home)) {
                $receipt = Get-Content (Join-Path $uvToolDir $toolInfo.tool 'uv-receipt.toml') | ConvertFrom-Toml
                UvToolInstallFromReceipt -ToolName $toolInfo.tool -Receipt $receipt -Force
            }
            else {
                Write-Host "Skipping '$($toolInfo.tool)': home path exists: $($cfgContent.home)"
            }
        }
        else {
            write-debug "Could not parse tool info from line: $_"
        }
    }
}
