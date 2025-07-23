$binPath = Resolve-Path "$PSScriptRoot\..\bin"
if (Test-Path -PathType Container $binPath) {
    $env:Path = "$binPath;$($env:Path)";
}
