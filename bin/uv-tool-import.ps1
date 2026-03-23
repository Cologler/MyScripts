param (
    # JSON input string. If not specified, the script will read from stdin.
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]
    $Json
    ,
    # Reinstall mode: do not detect whether a tool is already installed.
    [Parameter(Mandatory = $false)]
    [switch]
    $Reinstall
    ,
    # Optional tool name whitelist. When present, reinstall mode is enabled automatically.
    [Parameter(Mandatory = $false)]
    [string[]]
    $Tools,

    # Generate the command as text instead of executing it.
    [switch]
    $OutText
)

& {
    $ErrorActionPreference = 'Stop'

    Import-Module (Join-Path $PSScriptRoot '..' 'lib' 'uv.psm1') -Scope Local -DisableNameChecking

    $jsonText = $Json
    if ([string]::IsNullOrWhiteSpace($jsonText)) {
        if (-not $MyInvocation.ExpectingInput) {
            throw "Please pass export JSON via -Json or pipe it into this script."
        }
        $jsonText = Get-Content -Raw
    }

    if ([string]::IsNullOrWhiteSpace($jsonText)) {
        throw "Input JSON is empty."
    }

    $payload = $jsonText | ConvertFrom-Json
    if ($null -eq $payload) {
        throw "Failed to parse export JSON."
    }

    $effectiveReinstall = [bool]$Reinstall
    if ($null -ne $Tools -and $Tools.Count -gt 0) {
        $effectiveReinstall = $true
    }

    foreach ($prop in $payload.PSObject.Properties) {
        $toolName = $prop.Name
        $receipt = $prop.Value

        if ($null -ne $Tools -and $Tools.Count -gt 0) {
            if (-not ($Tools -contains $toolName)) {
                Write-Information "Skipping tool '$toolName' (not in -Tools list)."
                continue
            }
        }

        UvToolInstallFromReceipt -ToolName $toolName -Receipt $receipt -Reinstall:$effectiveReinstall `
            -OutText:$OutText
    }
}

