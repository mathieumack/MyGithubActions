param(
    [String] $query,
    [String] $skip = 0,
    [String] $take = 1
)

try {
    # Construct the appropriate API URL based on feed type
    $searchUrl = "https://api-v2v3search-0.nuget.org/query?q=$query&skip=$skip&take=$take"
    
    write-host "Searching for package on: $searchUrl"
    
    $response = Invoke-RestMethod -Uri $searchUrl -ErrorAction Stop
    $lastVersion = "1.0.0"
    
    if ($response.data.Count -eq 1)
    {
        # Package already found
        $versions = $response.data[0].versions
        if ($versions -and $versions.Count -gt 0) {
            # Find the absolute latest version (including previews)
            $latestVersion = $versions[-1].version
            write-host "Latest version found: $latestVersion"
            
            # Check if latest version is a preview/prerelease
            if ($latestVersion -match "^(\d+\.\d+\.\d+)(-preview-|-alpha-|-beta-)(.+)$") {
                # Latest is a preview - extract the base version
                $baseVersion = $matches[1]
                $prereleaseType = $matches[2]
                $prereleaseNumber = $matches[3]
                
                write-host "Latest version is a prerelease: base=$baseVersion, type=$prereleaseType, number=$prereleaseNumber"
                $lastVersion = $baseVersion
                
                # For PR builds, we'll keep the same base version and increment preview number
                # For main branch, we'll use this base version as-is
            } else {
                # Latest is stable - increment minor version for next preview
                if ($latestVersion -match "^(\d+)\.(\d+)\.(\d+)$") {
                    $major = [int]$matches[1]
                    $minor = [int]$matches[2] + 1
                    $patch = 0
                    $lastVersion = "$major.$minor.$patch"
                    
                    write-host "Latest version is stable: $latestVersion"
                    write-host "Next version will be: $lastVersion"
                } else {
                    # Fallback for malformed versions
                    $lastVersion = $latestVersion
                    write-host "Using latest version as-is: $lastVersion"
                }
            }

            # Display version information
            $versionSplited = $lastVersion.Split(".")
            write-host "Target base version:"
            write-host "    Major   : $($versionSplited[0])"
            write-host "    Minor   : $($versionSplited[1])"
            write-host "    Revision: $($versionSplited[2])"
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