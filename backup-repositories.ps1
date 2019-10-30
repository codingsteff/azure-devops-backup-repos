param([string] $organization, [string]$downloadLocation)

function get-projects {
    return (az devops project list -o json | ConvertFrom-Json) | Sort-Object name
}

function get-repos($project) {
    return (az repos list --project $project.name -o json | ConvertFrom-Json) | Sort-Object name
}

function backup-repo($project, $repo) {
    $repoName = $repo.name
    $projectName = $project.name
    Write-Host "   " $repoName
    $existProject = Test-Path $repoName
    if ($existProject) {
        $cmd = "git -C $repoName pull"
    }
    else {
        $cmd = "git clone https://$organization@dev.azure.com/$organization/$projectName/_git/$repoName $repoName"
    }
    Write-Host "      " $cmd
    Invoke-Expression $cmd
    Write-Host ""
}

if (-Not (Test-Path $downloadLocation)) {
    New-Item -Name $downloadLocation -ItemType Directory
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
            New-Item -Name $project.name -ItemType Directory
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