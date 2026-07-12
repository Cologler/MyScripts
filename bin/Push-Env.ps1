[CmdletBinding()]
param (
    [Parameter(Mandatory, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string] $Name,

    [Parameter(Mandatory, Position = 1)]
    [AllowEmptyString()]
    [string] $Value,

    [Parameter()]
    [string] $StackName = ''
)

if ($null -eq $global:__MyScripts__EnvStacks) {
    $global:__MyScripts__EnvStacks = @{}
}
if (-not $global:__MyScripts__EnvStacks.ContainsKey($StackName)) {
    $global:__MyScripts__EnvStacks[$StackName] = @{}
}
if (-not $global:__MyScripts__EnvStacks[$StackName].ContainsKey($Name)) {
    $global:__MyScripts__EnvStacks[$StackName][$Name] = [System.Collections.Generic.Stack[object]]::new()
}

$stack = $global:__MyScripts__EnvStacks[$StackName][$Name]
$item = Get-Item -LiteralPath "Env:$Name" -ErrorAction Ignore
Write-Verbose "Pushing environment variable '$Name' onto stack '$StackName' at depth $($stack.Count)."
Set-Item -LiteralPath "Env:$Name" -Value $Value -ErrorAction Stop
$stack.Push($item)
Write-Verbose "Set environment variable '$Name'; stack depth is now $($stack.Count)."
