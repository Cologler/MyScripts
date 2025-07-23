<#
.SYNOPSIS
    startup python venv environement
.DESCRIPTION
    This script checks if a Python virtual environment exists in the current directory.
    If it does not exist, it creates a new virtual environment.
    If it exists but requires an upgrade, it upgrades the existing virtual environment.
    Finally, it activates the virtual environment.
#>

[CmdletBinding()]
param (

)

function Test-VenvPath {
    param (
        [string] $Path
    )

    return (Test-Path -PathType Container $Path) -and (Test-Path -PathType Leaf "$Path/pyvenv.cfg")
}

function Get-VenvPath() {
    if (Test-VenvPath -Path '.venv') {
        return '.venv'
    }

    if (Test-Path -PathType Leaf 'poetry.lock') {
        return $(poetry env info -p)
    }

    return '.venv'
}

function Read-VenvCfg([string] $VenvPath) {
    $cfg = @{}
    Get-Content "$VenvPath/pyvenv.cfg"
        | Foreach-Object {
            $pairs = $_.Split('=');
            $cfg[$pairs[0].Trim()] = $pairs[1].Trim();
        }
    return $cfg
}

function Init-Venv([string] $VenvPath) {
    python -m venv --upgrade-deps $VenvPath
}

function Upgrade-Venv([string] $VenvPath) {
    python -m venv --upgrade $VenvPath
}

& {
    if ($env:VIRTUAL_ENV) {
        Write-Host "Virtual environment already activated: $env:VIRTUAL_ENV"
        return
    }

    $VenvPath = Get-VenvPath

    if (!(Test-VenvPath $VenvPath)) {
        Init-Venv $VenvPath
    }
    else {
        $cfg = Read-VenvCfg $VenvPath
        if (!(Test-Path $cfg['home'])) {
            Upgrade-Venv $VenvPath
        }
    }

    Invoke-Expression "$VenvPath/Scripts/Activate.ps1"
}
