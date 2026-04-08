param(
    [String] $prNumber,
    [String] $repo,
    [String] $token
)

# Check if we have a PR number
if ([string]::IsNullOrEmpty($prNumber)) {
    Write-Host "No PR number provided, skipping PR message check"
    Write-Output "false"
    exit 0
}

# Get the PR comments using GitHub API
$headers = @{
    "Accept" = "application/vnd.github+json"
    "Authorization" = "Bearer $token"
    "X-GitHub-Api-Version" = "2022-11-28"
}

try {
    # Get PR details
    $prUrl = "https://api.github.com/repos/$repo/pulls/$prNumber"
    Write-Host "Checking PR: $prUrl"
    $prResponse = Invoke-RestMethod -Uri $prUrl -Headers $headers -Method Get
    
    # Get PR comments
    $commentsUrl = "https://api.github.com/repos/$repo/issues/$prNumber/comments"
    $commentsResponse = Invoke-RestMethod -Uri $commentsUrl -Headers $headers -Method Get
    
    # Keywords to detect build/package requests
    $keywords = @(
        "request to build and package",
        "please build and package",
        "build and package this version",
        "publish to nuget",
        "release to nuget"
    )
    
    # Check PR body
    $prBody = $prResponse.body
    if (-not [string]::IsNullOrEmpty($prBody)) {
        foreach ($keyword in $keywords) {
            if ($prBody -match $keyword) {
                Write-Host "Found keyword '$keyword' in PR body"
                Write-Output "true"
                exit 0
            }
        }
    }
    
    # Check the last comment
    if ($commentsResponse.Count -gt 0) {
        $lastComment = $commentsResponse[-1]
        $commentBody = $lastComment.body
        Write-Host "Last comment by: $($lastComment.user.login)"
        Write-Host "Last comment: $commentBody"
        
        foreach ($keyword in $keywords) {
            if ($commentBody -match $keyword) {
                Write-Host "Found keyword '$keyword' in last comment"
                Write-Output "true"
                exit 0
            }
        }
    }
    
    Write-Host "No build/package request found in PR"
    Write-Output "false"
}
catch {
    Write-Host "Error checking PR message: $_"
    Write-Output "false"
}
