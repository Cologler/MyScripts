[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Tool,

    [Parameter()]
    [string[]]
    $Package
)

function Parse-UvToolList {
    param (
        [string]
        $text
    )

    if ($text -match '^(?<tool>\w+)\s+(?<version>v[\d\.]+)(?:\s+\[with:\s+(?<with>.+?)\])?$') {
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

& {
    $toolInfo = uv tool list --show-with --show-extras |
        ForEach-Object { Parse-UvToolList $_ } |
        where-object { $_.tool -eq $Tool }

    if (!$toolInfo) {
        write-error "Tool '$Tool' not found in the list of installed tools."
        exit 1
    }

    $command = New-Object System.Collections.Generic.List[string]

    $command.Add('uv.exe')
    $command.Add('tool')
    $command.Add('install')
    $command.Add($Tool)

    foreach ($package in $toolInfo.with + $Package) {
        $command.Add('--with')
        $command.Add($package)
    }

    & $command[0] @($command[1..($command.Count - 1)])
}
