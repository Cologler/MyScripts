param (
    [Parameter(Mandatory = $true)]
    [string]
    $InPath,

    [string]
    $OutPath
)

if (!$OutPath) {
    $dirname = [System.IO.Path]::GetDirectoryName($InPath)
    $prefix = [System.IO.Path]::GetFileNameWithoutExtension($InPath);
    $suffix = [System.IO.Path]::GetExtension($InPath);
    $OutPath = "$dirname\$prefix.utf-8$suffix";
}

function Get-Encoding {
    $out = chardetect $InPath
    if ($out -match '^.*: (.*) with confidence .*$') {
        return $Matches[1]
    }
}

$encoding = Get-Encoding
if ($encoding) {
    iconv -f $encoding -t 'utf-8' -o $OutPath $InPath
}
