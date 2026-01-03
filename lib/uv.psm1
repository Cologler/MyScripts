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
