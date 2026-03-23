[CmdletBinding()]
param (
    [switch]
    $python
)

& {
    Import-Module (Join-Path $PSScriptRoot '..' 'lib' 'uv.psm1') -Scope Local -DisableNameChecking

    $tools = Get-UvTools

    if ($python) {
        $tools | Format-Table Tool, PythonVersion, Home -AutoSize
    }
    else {
        $tools | Format-Table Tool, Version, With -AutoSize
    }
}