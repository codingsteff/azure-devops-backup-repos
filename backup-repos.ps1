param([string] $organization, [string]$downloadLocation, [string]$personalAccessToken)

function Get-Projects {
    return (az devops project list -o json | ConvertFrom-Json) | Sort-Object name
}

function Get-Repos($project) {
    return (az repos list --project $project.name -o json | ConvertFrom-Json) | Sort-Object name
}

function Add-Token($url, $token) {
    if ($token) {
        $delimiter = $url.indexOf("@")
        $url = $url.Substring(0, $delimiter) + ":$token" + $url.Substring($delimiter)
    }
    return $url
}

function Backup-Repo($project, $repo) {
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
    $cmd = Add-Token $cmd $personalAccessToken
    Invoke-Expression $cmd
    Write-Host ""
}

function Backup-Repos() {
    $projects = Get-Projects
    foreach ($project in $projects) {
        Write-Host $project.name
        $repos = Get-Repos($project)
        $hasMultiRepos = $repos.Length -gt 1
        if ($hasMultiRepos) {
            # Activate chain operator as soon as Powershell 7 GA
            #Test-Path $project.name || New-Item -Name $project.name -ItemType Directory
            $existFolder = (Test-Path $project.name)
            if (-Not $existFolder) {
                New-Item -Name $project.name -ItemType Directory | Out-Null
            }
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
# Activate chain operator as soon as Powershell 7 GA
#Test-Path $downloadLocation || New-Item -Name $downloadLocation -ItemType Directory
if (-Not (Test-Path $downloadLocation)) {
    New-Item -Name $downloadLocation -ItemType Directory | Out-Null
} 
Set-Location $downloadLocation
Backup-Repos

Set-Location $location