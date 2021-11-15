# create a temporary directory and set as work directory.

function New-TemporaryDirectory {
    $name  = 'tmpwd-'
    $name += [System.DateTime]::Now.ToString('yyyyMMdd')
    $name += '-'
    $name += $(New-Guid).ToString().Replace('-', '').SubString(8)
    $tempFolderPath = Join-Path $Env:Temp $name
    New-Item -Type Directory -Path $tempFolderPath | Out-Null
    return $tempFolderPath
}

Push-Location $(New-TemporaryDirectory)

Write-Host -NoNewline 'type '
Write-Host -NoNewline -ForegroundColor Green ``Pop-Location``
Write-Host ' to exit the temporary directory.'
