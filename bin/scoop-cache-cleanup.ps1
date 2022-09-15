# cleanup scoop cache directory,
# unlike `scoop cache clean`,
# this will keep the least install packages

using namespace System.Collections.Generic;
using namespace System.Linq;

$ScoopCache = Resolve-Path -Path "~/Scoop/cache"

$Files = Get-Childitem -Path $ScoopCache

$FilesSet = [HashSet[string]]::new()
$Files | ForEach-Object { $FilesSet.Add($_.Name) } | Out-Null

$Files
| ForEach-Object {
    if ($_.Name -match "^(?<app>.+)#(?<ver>.+)#http.+$") {
        if (!$FilesSet.Contains($_.Name + '.aria2')) {
            $app = $Matches.app
            $ver = $Matches.ver
            $time = $_.LastWriteTimeUtc
            return @{
                App = $app
                Ver = $ver
                Time = $time
                Path = $_.FullName
            }
        }
    }
    return $null
}
| Sort-Object -Property Time
| Where-Object { $_ -ne $null }
| Group-Object -Property App
| Where-Object { $_.Count -gt 1 }
| ForEach-Object {
    foreach ($oldItem in [Enumerable]::Take($_.Group, $_.Count - 1)) {
        Remove-Item -Path $oldItem.Path
        Write-Output "Removed $($oldItem.Path)"
    }
}
