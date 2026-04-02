param(
    [string] $Name,
    [string] $Replacement = "_"
)

# Get invalid filename characters
$invalid = [System.IO.Path]::GetInvalidFileNameChars()

foreach ($char in $invalid) {
    $Name = $Name -replace [regex]::Escape($char), $Replacement
}

return $Name
