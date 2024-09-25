
Get-ChildItem ~/scoop/apps/* |
    ForEach-Object {
        if (Test-Path "$_/current/manifest.json") {
            $manifest = Get-Content "$_/current/manifest.json" | ConvertFrom-Json
            return [PSCustomObject] @{
                App = $_.Name
                Description = $manifest.description
            }
        }
    } |
    Format-Table -Wrap