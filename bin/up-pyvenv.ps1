# startup python venv environement
# - If not create, create it;
# - If upgrade required, upgrade it;

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

$VenvPath = '.venv'

if (!(Test-Path $VenvPath)) {
    Init-Venv $VenvPath
} else {
    $cfg = Read-VenvCfg $VenvPath
    if (!(Test-Path $cfg['home'])) {
        Upgrade-Venv $VenvPath
    }
}
Invoke-Expression "$VenvPath/Scripts/Activate.ps1"
