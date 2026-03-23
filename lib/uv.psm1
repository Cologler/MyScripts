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

function Invoke-UvToolInstall {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Tool,

        [string[]]
        $Withs,

        [switch]
        $Force,

        [switch]
        $Reinstall,

        [string]
        $Python,

        [switch]
        $OutText
    )

    $cmdExec = 'uv.exe'
    $cmdArgs = New-Object System.Collections.Generic.List[string]

    $cmdArgs.Add('tool')
    $cmdArgs.Add('install')
    if ($Reinstall) {
        $cmdArgs.Add('--reinstall')
    }
    if ($Force) {
        $cmdArgs.Add('--force')
    }
    if ($Python) {
        $cmdArgs.Add('--python')
        $cmdArgs.Add($Python)
    }
    $cmdArgs.Add($Tool)
    foreach ($pkg in $Withs) {
        $cmdArgs.Add('--with')
        $cmdArgs.Add($pkg)
    }

    function Get-ArgText([string] $s) {
        if ($null -eq $s) { return '' }
        # Display-oriented quoting only.
        if ($s -match '\s') {
            return '"' + ($s -replace '"', '\"') + '"'
        }
        return $s
    }

    $cmdArgsText = ($cmdArgs | ForEach-Object { Get-ArgText $_ }) -join ' '
    Write-Host "#> $cmdExec $cmdArgsText" -ForegroundColor Cyan

    if ($OutText) {
        Write-Output "$cmdExec $cmdArgsText"
    }
    else {
        & $cmdExec @cmdArgs
    }
}

function Invoke-UvToolInstallFromReceipt {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ToolName,

        [Parameter(Mandatory = $true)]
        $Receipt,

        [switch]
        $Force,

        [switch]
        $Reinstall,

        [switch]
        $OutText
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

    $invokeParams = @{
        Tool      = Get-PackageInstallLocation $tool
        Withs     = $withs | ForEach-Object { Get-PackageInstallLocation $_ }
        Force     = $Force
        Reinstall = $Reinstall
        OutText   = $OutText
    }

    if ($Receipt.tool.python) {
        $invokeParams.Python = $Receipt.tool.python
    }

    Invoke-UvToolInstall @invokeParams
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
