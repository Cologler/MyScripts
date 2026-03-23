function Parse-UvToolList {
    param (
        [string]
        $text
    )

    if ($text -match '^(?<tool>[\w\-]+)\s+(?<version>v[\d\w\.\+\-]+)(?:\s+\[with:\s+(?<with>.+?)\])?$') {
        $tool = $matches['tool']
        $version = $matches['version']
        $with = @()
        if ($matches['with']) {
            $with = $matches['with'] -split '\s*,\s*'
        }

        return [pscustomobject]@{
            tool    = $tool
            version = $version
            with    = $with
        }
    }
}

# parse pyvenv.cfg file
function Parse-PyvenvCfg {
    param (
        [string]
        $cfgPath
    )

    $result = @{}

    if (Test-Path $cfgPath) {
        foreach ($line in Get-Content $cfgPath) {
            if ($line -match '^\s*(?<key>[^=]+)\s*=\s*(?<value>.+)$') {
                $key = $Matches['key'].Trim()
                $value = $Matches['value'].Trim()
                $result[$key] = $value
            }
        }
    }

    return $result
}

function UvToolInstall {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Tool,

        [string[]]
        $Withs,

        [switch]
        $Force
    )

    $command = New-Object System.Collections.Generic.List[string]

    $command.Add('uv.exe')
    $command.Add('tool')
    $command.Add('install')
    if ($Force) {
        $command.Add('--force')
    }
    $command.Add($Tool)
    foreach ($pkg in $Withs) {
        $command.Add('--with')
        $command.Add($pkg)
    }

    & $command[0] @($command[1..($command.Count - 1)])
}

function UvToolInstallFromReceipt {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ToolName,

        [Parameter(Mandatory = $true)]
        $Receipt,

        [switch]
        $Force
    )

    $tool = $Receipt.tool.requirements | Where-Object { $_.name -eq $ToolName }
    $withs = $Receipt.tool.requirements | Where-Object { $_.name -ne $ToolName }

    function Get-PackageInstallLocation($requirement) {
        if ($requirement.git) {
            return "git+$($requirement.git)"
        }
        elseif ($requirement.directory) {
            return "file:///$($requirement.directory)"
        }
        else {
            return $requirement.name
        }
    }

    UvToolInstall `
        -Tool (Get-PackageInstallLocation $tool) `
        -Withs ($withs | ForEach-Object { Get-PackageInstallLocation $_ }) `
        -Force:$Force
}

function Get-UvToolDir {
    $uvToolDir = uv tool dir 2>$null
    if (-not $uvToolDir -or -not (Test-Path $uvToolDir)) {
        throw "uv tool dir did not return a valid path: $uvToolDir"
    }

    return $uvToolDir
}

function Get-UvTools {
    param (
    )

    $uvToolDir = Get-UvToolDir

    $tools = @()
    uv tool list --show-with --show-extras | ForEach-Object {
        if ($_ -match '^-') {
            # execute program name
            return
        }

        $toolInfo = Parse-UvToolList $_
        if ($toolInfo) {
            $cfgPath = Join-Path $uvToolDir $toolInfo.tool 'pyvenv.cfg'
            $cfgContent = Parse-PyvenvCfg -cfgPath $cfgPath

            $tools += [pscustomobject]@{
                Tool    = $toolInfo.tool
                Version = $toolInfo.version
                With    = $toolInfo.with -join ', '
                Home    = $cfgContent.home
                PythonVersion = $cfgContent.version_info
            }
        }
    }
    return $tools
}
