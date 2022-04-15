function Parse-Path([string] $content) {
    # TODO: parse with "...";"..."
    return $content.Split(';');
}

foreach ($item in $(Parse-Path $env:path)) {
    Write-Output $item
}
