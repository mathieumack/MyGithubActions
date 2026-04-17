param(
    [String] $query,
    [String] $skip = 0,
    [String] $take = 1,
    [String] $feedUrl = "https://api-v2v3search-0.nuget.org",
    [bool] $isMainBranch = $false
)

try {
    # Construct the appropriate API URL based on feed type
    $searchUrl = "$feedUrl/query?q=$query&skip=$skip&take=$take&prerelease=true"
    
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
                
                # For main branch, use this base version as-is
                # For PR builds, we'll keep the same base version and increment preview number
                $lastVersion = $baseVersion
            } else {
                # Latest is stable - increment minor version for next preview/release
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

# Handle preview versioning for non-main branches
if (-not $isMainBranch) {
    write-host "This is a preview build, calculating preview version..."
    $previewNumber = 1
    
    try {
        # Use the already retrieved versions from the initial query
        if ($response.data.Count -eq 1) {
            # Get all versions and find previews for our base version
            $allVersions = $response.data[0].versions
            Write-Host "Found $($allVersions.Count) total versions, searching for previews of $lastVersion"
            
            # Find all preview versions that match our target base version
            $matchingPreviews = @()
            foreach ($version in $allVersions) {
                if ($version.version -like "$lastVersion-preview-*") {
                    Write-Host "Found preview version: $($version.version)"
                    $matchingPreviews += $version
                }
            }
            
            if ($matchingPreviews.Count -gt 0) {
                # Extract preview numbers and find the highest one
                $previewNumbers = @()
                foreach ($preview in $matchingPreviews) {
                    if ($preview.version -match "^$lastVersion-preview-(\d+)$") {
                        $previewNumber = [int]$matches[1]
                        $previewNumbers += $previewNumber
                        Write-Host "Extracted preview number $previewNumber from $($preview.version)"
                    }
                }
                
                if ($previewNumbers.Count -gt 0) {
                    $maxPreviewNumber = ($previewNumbers | Measure-Object -Maximum).Maximum
                    $previewNumber = $maxPreviewNumber + 1
                    
                    Write-Host "Found $($matchingPreviews.Count) existing preview(s) for base version $lastVersion"
                    Write-Host "Highest preview number: $maxPreviewNumber"
                    Write-Host "Next preview number: $previewNumber"
                } else {
                    Write-Host "Could not parse preview numbers, starting at 1"
                    $previewNumber = 1
                }
            } else {
                Write-Host "No existing previews found for base version $lastVersion, starting at 1"
                $previewNumber = 1
            }
        }
    }
    catch {
        Write-Host "Warning: Could not analyze preview versions: $_"
        Write-Host "Defaulting to preview number 1"
        $previewNumber = 1
    }
    
    # Format preview number and append to version
    $formattedPreviewNumber = $previewNumber.ToString("000")
    $lastVersion = "$lastVersion-preview-$formattedPreviewNumber"
    
    Write-Host "Final preview version: $lastVersion"
}

write-output $lastVersion