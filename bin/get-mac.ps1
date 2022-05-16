[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $IP
)

$NetNeighbor = (Get-NetNeighbor | Where-Object -Property IPAddress -EQ $IP)

if ($NetNeighbor) {
    Write-Output $($NetNeighbor.LinkLayerAddress)
}
