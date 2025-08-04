[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Tool,

    [Parameter(Mandatory = $true, ValueFromRemainingArguments=$true)]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $Package
)

& {
    Import-Module (Join-Path $PSScriptRoot '..' 'lib' 'uv.psm1') -Scope Local

    $toolInfo = uv tool list --show-with --show-extras |
        ForEach-Object { Parse-UvToolList $_ } |
        where-object { $_.tool -eq $Tool }

    if (!$toolInfo) {
        write-error "Tool '$Tool' not found in the list of installed tools."
        exit 1
    }

    if (!($toolInfo.with -contains $Package)) {
        Write-Error "No with match $package"
        exit 1
    }

    $command = New-Object System.Collections.Generic.List[string]

    $command.Add('uv.exe')
    $command.Add('tool')
    $command.Add('install')
    $command.Add($Tool)

    foreach ($pkg in $toolInfo.with) {
        if ($pkg -ne $Package) {
            $command.Add('--with')
            $command.Add($pkg)
        }
    }

    & $command[0] @($command[1..($command.Count - 1)])
}

