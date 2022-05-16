[CmdletBinding()]
param (
    [string]
    $MAC,

    [string]
    $IP
)

if (!$IP -and !$MAC) {
    Write-Error "No MAC address or IP address specified" -ErrorAction Stop
}

if ($IP -and !$MAC) {
    $NetNeighbor_ByIP = (Get-NetNeighbor | Where-Object -Property IPAddress -EQ $IP)
    if ($NetNeighbor_ByIP) {
        $MAC = $NetNeighbor_ByIP.LinkLayerAddress
    }
    else {
        Write-Error "No MAC address found for IP address $IP" -ErrorAction Stop
    }
}

if ($MAC) {
    $NetNeighbor = (Get-NetNeighbor | Where-Object -Property LinkLayerAddress -EQ $MAC)
}

if ($NetNeighbor) {
    Write-Output $($NetNeighbor.IPAddress)
}
