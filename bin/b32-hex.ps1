<#
.SYNOPSIS
    Convert base32 string to hex string.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [string]
    $str
)

process {
     $str | busybox base32 -d | busybox xxd -p
}
