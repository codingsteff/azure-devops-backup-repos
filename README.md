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

```sh
.\backup-repos.ps1 "organization" "/repos" "[personal-access-token]"
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
docker build -t azure-devops-backup-repos .
```

## Docker hub

### Build Rules

| Type   | Source                             | Docker Tag                      |
| ------ | ---------------------------------- | ------------------------------- |
| Branch | `master`                           | `latest`                        |
| Tag    | `/([0-9]+)?(\.[0-9]+)?(\.[0-9]+)/` | `{\1}`,`{\1}{\2}`,`{sourceref}` |

Multiple docker tags: *Regex with capture groups {\1} for major, {\2} for minor, {soureref} for full tag name*

[Regexes and automated builds](https://docs.docker.com/docker-hub/builds/#regexes-and-automated-builds)
