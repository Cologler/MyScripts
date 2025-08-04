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
