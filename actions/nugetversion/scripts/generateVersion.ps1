param(
    [String] $query,
    [String] $skip = 0,
    [String] $take = 1,
    [ValidateSet('major', 'minor', 'patch')]
    [String] $increment = 'minor'
)

$response = Invoke-RestMethod -Uri "https://api-v2v3search-0.nuget.org/query?q=$query&skip=$skip&take=$take"
$lastVersion = "1.0.0"

if ($response.data.Count -eq 1)
{
    # Package already exists
    $lastVersion = $response.data[0].versions[$response.data[0].versions.Count - 1].version
    
    # Remove any pre-release suffix (e.g., -preview-001)
    if ($lastVersion -match '^(\d+\.\d+\.\d+)') {
        $lastVersion = $matches[1]
    }
    
    write-host "Last published version: $lastVersion"

    # Parse version components
    $versionParts = $lastVersion.Split(".")
    [int]$major = $versionParts[0]
    [int]$minor = $versionParts[1]
    [int]$patch = $versionParts[2]

    write-host "    Major   : $major"
    write-host "    Minor   : $minor"
    write-host "    Patch   : $patch"

    # Increment version based on parameter
    switch ($increment) {
        'major' {
            $major++
            $minor = 0
            $patch = 0
        }
        'minor' {
            $minor++
            $patch = 0
        }
        'patch' {
            $patch++
        }
    }

    $lastVersion = "$major.$minor.$patch"
}
else {
    write-host "Package not found, using initial version: $lastVersion"
}

$versionParts = $lastVersion.Split(".")
write-host "New version ($increment increment):"
write-host "    Major   : $($versionParts[0])"
write-host "    Minor   : $($versionParts[1])"
write-host "    Patch   : $($versionParts[2])"

write-output $lastVersion