param([string] $organization, [string]$downloadLocation, [string]$personalAccessToken)

function Get-Projects {
    # Workaround: .value from ConvertFrom-Json, else it returs continuationToken+value?? 
    return (az devops project list -o json | ConvertFrom-Json).value | Sort-Object name
}

function Get-Repos($project) {
    return (az repos list --project $project.id -o json | ConvertFrom-Json) | Sort-Object name
}

function Add-Token($url, $token) {
    if ($token) {
        $delimiter = $url.indexOf("@")
        $url = $url.Substring(0, $delimiter) + ":$token" + $url.Substring($delimiter)
    }
    return $url
}

function Add-Directory($directory) {
    if (!(Test-Path -path $directory)) {
        New-Item $directory -ItemType Directory | Out-Null
    }
}

function Backup-Repo($project, $repo) {
    $repoName = $repo.name
    $projectName = $project.name
    $url = $repo.remoteUrl
    Write-Host "   " $repoName
    $existProject = Test-Path $repoName
    if ($existProject) {
        # Invoke-Expression "git remote prune origin"
        $cmd = "git -C $repoName pull $url"
    }
    else {          
        $cmd = "git clone $url $repoName"
    }
    Write-Host "      " $cmd
    $cmd = Add-Token $cmd $personalAccessToken
    Invoke-Expression $cmd
    Write-Host ""
}

function Backup-Repos() {
    $projects = Get-Projects
    foreach ($project in $projects) {
        Write-Host $project.name
        $repos = Get-Repos($project)
        if ($repos.Length -eq 0) {
            Write-Host 'No repos!'
        }
        elseif ($repos.Length -gt 1) {
            Add-Directory $project.name
            # TODO: Remove ugly Set-Locations
            # Problem 1: git pull on sub directory
            # Problem 2: invoke-expression alternative?
            # Improvements: if problems away, then use -parallel foreach
            Set-Location $project.name
            foreach ($repo in $repos) {
                Backup-Repo $project $repo
            }
            Set-Location ..
        }
        else {
            $repo = $repos[0]        
            Backup-Repo $project $repo
        }
    }
}

$location = Get-Location
Add-Directory $downloadLocation
Set-Location $downloadLocation
Backup-Repos

Set-Location $location