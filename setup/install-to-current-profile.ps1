param (
    [switch] $AllHosts
)

$profileToWrite = if ($AllHosts) { $profile.CurrentUserAllHosts } else { $profile }

$installShellScriptPath = Resolve-Path "$PSScriptRoot\install-to-current-shell.ps1"

'# add MyScripts' >> $profileToWrite
$body = "& `'$installShellScriptPath`'"
$body >> $profileToWrite

Write-Host "Written to $profileToWrite"
