param(
    [string]$organization,
    [string]$downloadLocation,
    [string]$personalAccessToken,
    [switch]$backupAllBranches,
    [string]$branchNameRegex = ".*" # Default: matches all branches
)

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

function Invoke-AuthenticatedGitCommand($command, $token) {
    Write-Host "      " $command
    $tokenizedCommand = Add-Token $command $token
    $result = Invoke-Expression $tokenizedCommand
    Write-Host ""
    return $result
}

function Backup-Repo($project, $repo) {
    $repoName = $repo.name
    $projectName = $project.name
    $url = $repo.remoteUrl
    Write-Host "   " $repoName
    $existRepo = Test-Path $repoName

    if ($backupAllBranches) {
        # Back up all branches
        if (!($existRepo)) {
            Add-Directory $repoName
        }
        # Save current directory to return to it later
        $currentDir = Get-Location
        try {
            Set-Location -Path $repoName

            # List branch refs
            $cmd = "git ls-remote --heads $url"
            $refs = Invoke-AuthenticatedGitCommand $cmd $personalAccessToken

            # Extract branch names and filter based on the provided regex pattern
            $branches = $refs |
                ForEach-Object { ($_ -split "\s+")[1] -replace "^refs/heads/", "" } |
                Where-Object { $_ -match $branchNameRegex }

            if (-not $branches) {
                Write-Warning "      No branches matched the filter '$branchNameRegex'."
                return
            }
            
            # Clone each branch into its own folder
            foreach ($branch in $branches) {
                # Replace all punctuation (except letters, numbers, and underscore) with "_"
                $branchDir = "$branch" -replace '[^\w]', '_'

                $existBranch = Test-Path $branchDir
                if ($existBranch) {
                    # Fetch changes and update the local branch
                    $cmd = "git -C '$branchDir' pull $url $branch"
                }
                else {   
                    # Clone the remote branch into a new directory       
                    $cmd = "git clone --single-branch --branch $branch $url '$branchDir'"
                }
                Invoke-AuthenticatedGitCommand $cmd $personalAccessToken
            }
        }
        finally {
                # Always return to previous directory
                Set-Location $currentDir
            }
    }
    else {
        # Back up main / master branch only
        if ($existRepo) {
            # Invoke-Expression "git remote prune origin"
            $cmd = "git -C $repoName pull $url"
        }
        else {          
            $cmd = "git clone $url $repoName"
        }
        Invoke-AuthenticatedGitCommand $cmd $personalAccessToken
    }
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

            # Save current directory to return to it later
            $currentDir = Get-Location
            try {
                Set-Location $project.name
                foreach ($repo in $repos) {
                    Backup-Repo $project $repo
                }
            }
            finally {
                # Always return to previous directory
                Set-Location $currentDir
            }
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
