param (
    [switch] $AllHosts
)

$profileToWrite = if ($AllHosts) { $profile.CurrentUserAllHosts } else { $profile }

$binPath = Resolve-Path "$PSScriptRoot\..\bin"
$body = `
"`$env:Path = '$binPath;' + `$env:Path;";
$body >> $profileToWrite
Write-Host "Written to $profileToWrite"
