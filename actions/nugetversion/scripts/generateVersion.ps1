param(
    [String] $query,
    [String] $skip = 0,
    [String] $take = 1
)

try {
    $response = Invoke-RestMethod -Uri "https://api-v2v3search-0.nuget.org/query?q=$query&skip=$skip&take=$take" -ErrorAction Stop
    $lastVersion = "1.0.0"
    
    if ($response.data.Count -eq 1)
    {
        # Package already found
        $versions = $response.data[0].versions
        if ($versions -and $versions.Count -gt 0) {
            # Get the last stable version (without preview suffix)
            $stableVersions = $versions | Where-Object { $_.version -notmatch "-preview-" -and $_.version -notmatch "-alpha" -and $_.version -notmatch "-beta" }
            
            if ($stableVersions -and $stableVersions.Count -gt 0) {
                $lastVersion = $stableVersions[-1].version
                write-host "Last stable version found: $lastVersion"
            } else {
                # If no stable version, take the last version overall
                $lastVersion = $versions[-1].version
                write-host "No stable version found, using last version: $lastVersion"
                # Remove suffixes to get base version
                if ($lastVersion -match "^(\d+\.\d+\.\d+)") {
                    $lastVersion = $matches[1]
                    write-host "Extracted base version: $lastVersion"
                }
            }

            # We have to increment from last published version
            $versionSplited = $lastVersion.Split(".")
            write-host "    Major   : $($versionSplited[0])"
            write-host "    Minor   : $($versionSplited[1])"
            write-host "    Revision: $($versionSplited[2])"

            # Calculate new version
            $lastVersion = $versionSplited[0] + "." + ([int]$versionSplited[1] + 1) + ".0"
        }
    } else {
        write-host "Package not found on NuGet, using default version: $lastVersion"
    }
} catch {
    write-host "Error querying NuGet API: $_"
    write-host "Using default version: 1.0.0"
    $lastVersion = "1.0.0"
}

$versionSplited = $lastVersion.Split(".")
write-host "New version:"
write-host "    Major   : $($versionSplited[0])"
write-host "    Minor   : $($versionSplited[1])"
write-host "    Revision: $($versionSplited[2])"

write-output $lastVersion