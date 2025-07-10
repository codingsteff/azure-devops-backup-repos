# Azure DevOps - Backup Repositories

Powershell script to download all Azure DevOps git repositories with use of git clone or pull.

## Requirements

[Azure DevOps Extension for Azure CLI](https://github.com/Azure/azure-devops-cli-extension)

```sh
# login interactive
az devops login

# login with Personal Access Token
az devops login --organization https://dev.azure.com/[ORGANIZATION]
```

## Usage

### Back up main / master branch only
```sh
.\backup-repos.ps1 
    -organization "organization"
    -downloadLocation "/repos"
    -personalAccessToken "[personal-access-token]"
```

### Back up all branches
```sh
.\backup-repos.ps1 
    -organization "organization"
    -downloadLocation "/repos"
    -personalAccessToken "[personal-access-token]"
    -backupAllBranches
```

### Back up specific branches based on regex pattern (e.g. only main and any release/ branches.)
```sh
.\backup-repos.ps1 
    -organization "organization"
    -downloadLocation "/repos"
    -personalAccessToken "[personal-access-token]"
    -backupAllBranches
    -branchNameRegex "^main$|^release\/"
```

*Personal access token is optional, otherwise it uses system configured git credentials.*

## Run as docker container

```sh
docker run /
-e AZURE_DEVOPS_EXT_ORG=contoso /
-e AZURE_DEVOPS_EXT_PAT=xxxxxxxx /
-v /repos:/repos /
codingsteff/azure-devops-backup-repos
```

## Dev

### Build local docker container

```sh
docker build --pull -t azure-devops-backup-repos .
```

### Create Tags

```sh
git tag 1.0.x
git push origin --tags
```

## Docker hub

### Build Rules

| Type   | Source becomes =>                  | Docker Tag                      |
| ------ | ---------------------------------- | ------------------------------- |
| Branch | `master`                           | `latest`                        |
| Tag    | `/([0-9]+)?(\.[0-9]+)?(\.[0-9]+)/` | `{\1}`,`{\1}{\2}`,`{sourceref}` |

Multiple docker tags: *Regex with capture groups {\1} for major, {\2} for minor, {soureref} for full tag name*

[Regexes and automated builds](https://docs.docker.com/docker-hub/builds/#regexes-and-automated-builds)
