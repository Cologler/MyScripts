[CmdletBinding()]
param (
    [Parameter(Mandatory, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string] $Name,

    [Parameter()]
    [string] $StackName = ''
)

$namedStacks = $null
if ($null -ne $global:__MyScripts__EnvStacks) {
    $namedStacks = $global:__MyScripts__EnvStacks[$StackName]
}
if ($StackName -ne '' -and $null -eq $namedStacks) {
    Write-Warning "Environment stack '$StackName' does not exist."
    return
}
$stack = $null
if ($null -ne $namedStacks) {
    $stack = $namedStacks[$Name]
}
if ($null -eq $stack -or $stack.Count -eq 0) {
    Write-Debug "Environment stack '$StackName' for '$Name' is empty; nothing to restore."
    return
}

$item = $stack.Peek()
Write-Verbose "Restoring environment variable '$Name' from stack '$StackName' at depth $($stack.Count)."
if ($null -ne $item) {
    Set-Item -LiteralPath "Env:$Name" -Value $item.Value -ErrorAction Stop
}
else {
    Remove-Item -LiteralPath "Env:$Name" -ErrorAction Stop
}
$null = $stack.Pop()
Write-Verbose "Restored environment variable '$Name'; stack depth is now $($stack.Count)."
