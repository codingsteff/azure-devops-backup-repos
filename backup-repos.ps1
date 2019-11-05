param([string] $organization, [string]$downloadLocation, [string]$personalAccessToken)

function get-projects {
    return (az devops project list -o json | ConvertFrom-Json) | Sort-Object name
}

function get-repos($project) {
    return (az repos list --project $project.name -o json | ConvertFrom-Json) | Sort-Object name
}

function backup-repo($project, $repo) {
    $repoName = $repo.name
    $projectName = $project.name
    $url = "https://$organization@dev.azure.com/$organization/$projectName/_git/$repoName"
    Write-Host "   " $repoName
    $existProject = Test-Path $repoName
    if ($existProject) {
        $cmd = "git -C $repoName pull $url"
    }
    else {          
        $cmd = "git clone $url $repoName"
    }
    Write-Host "      " $cmd
    $cmd = add-token $cmd $personalAccessToken
    Invoke-Expression $cmd
    Write-Host ""
}

function add-token($url, $token) {
    if ($token) {
        $delimiter = $url.indexOf("@")
        $url = $url.Substring(0, $delimiter) + ":$token" + $url.Substring($delimiter)
    }
    return $url
}

if (-Not (Test-Path $downloadLocation)) {
    New-Item -Name $downloadLocation -ItemType Directory | Out-Null
}
$location = Get-Location
Set-Location $downloadLocation
$projects = get-projects
foreach ($project in $projects) {
    Write-Host $project.name
    $repos = get-repos($project)
    $hasMultiRepos = $repos.Length -gt 1
    if ($hasMultiRepos) {
        $existFolder = (Test-Path $project.name)
        if (-Not $existFolder) {
            New-Item -Name $project.name -ItemType Directory | Out-Null
        }
        Set-Location $project.name
        foreach ($repo in $repos) {
            backup-repo $project $repo
        }
        Set-Location ..
    }
    else {
        $repo = $repos[0]        
        backup-repo $project $repo
    }
}
Set-Location $location