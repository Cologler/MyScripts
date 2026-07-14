<#
.SYNOPSIS
    Displays a table of IP prefix masks.

.DESCRIPTION
    Displays binary, decimal, hexadecimal, and address count values for every IP prefix mask
    from zero bits through the selected width.
    The default width is 8 bits.

.PARAMETER bits
    The number of bits to display. The default is 8.

.EXAMPLE
    ip-prefix-mask-table

    Displays the 8-bit mask table.

.EXAMPLE
    ip-prefix-mask-table -bits 4

    Displays the 4-bit mask table.
#>

[CmdletBinding()]
param (
    [ValidateRange(1, [int]::MaxValue)]
    [int]
    $bits = 8
)

Set-StrictMode -Version 3.0

$bits..0 | ForEach-Object {
    $prefixLength = $bits - $_
    $count = [System.Numerics.BigInteger]::Pow(2, $_)
    $dec = [System.Numerics.BigInteger]::Pow(2, $bits) - $count

    [pscustomobject]@{
        bin   = ('1' * $prefixLength).PadRight($bits, '0')
        dec   = $dec
        hex   = $dec.ToString('X').TrimStart('0').PadLeft(1, '0')
        count = $count
    }
} | Format-Table bin, dec, hex, count -AutoSize
