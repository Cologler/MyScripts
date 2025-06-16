<#
.SYNOPSIS
    Convert hex string to base32 string.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [string]
    $str
)

process {
     $str | busybox xxd -r -p | busybox base32
}