[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [ipaddress]
    $IP
)

# https://api.iplocation.net/

$response = Invoke-WebRequest "https://api.iplocation.net/?ip=$IP"

if ($response.StatusCode -eq 200) {
    $content = ($response.Content | ConvertFrom-Json)

    $ip = $content.ip
    $countryCode = $content.country_code2
    $countryName = $content.country_name
    $isp = $content.isp

    Write-Host "IP: $ip"
    Write-Host "Location: ($countryCode) $countryName"
    Write-Host "ISP: $isp"
}
