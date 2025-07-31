<#
.SYNOPSIS
    Replace the basename of items.
#>

param (
    [Parameter(Position=0, Mandatory=$true)]
    [string] $FromValue,

    [Parameter(Position=1, Mandatory=$true)]
    [string] $ToValue,

    [Parameter(ValueFromPipeline = $true)]
    [ValidateNotNull()]
    [string] $InputObject
)

process {
    $name = Split-Path -Leaf $InputObject
    $base = Split-Path -LeafBase $InputObject
    $ext = Split-Path -Extension $InputObject
    $newBaseName = $base.Replace($FromValue, $ToValue)
    $newName = "$newBaseName$ext"

    if ($name -ne $newName) {
        Write-Host "$name -> $newName"
        Rename-Item $InputObject $newName
    }
}