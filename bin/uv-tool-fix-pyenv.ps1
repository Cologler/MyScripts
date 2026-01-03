[CmdletBinding()]
param ()

& {
    Import-Module (Join-Path $PSScriptRoot '..' 'lib' 'uv.psm1') -Scope Local

    $uvToolDir = uv tool dir 2>$null
    if (-not $uvToolDir -or -not (Test-Path $uvToolDir)) {
        throw "uv tool dir did not return a valid path: $uvToolDir"
    }

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
                $command = New-Object System.Collections.Generic.List[string]

                $command.Add('uv.exe')
                $command.Add('tool')
                $command.Add('install')
                $command.Add('--force')
                $command.Add($toolInfo.tool)

                foreach ($pkg in $toolInfo.with) {
                    $command.Add('--with')
                    $command.Add($pkg)
                }

                & $command[0] @($command[1..($command.Count - 1)])
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
