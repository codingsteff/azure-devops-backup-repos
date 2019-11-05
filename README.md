# Azure DevOps - Backup Repositories

Powershell script to download all Azure DevOps git repositories with use of git clone or pull.

## Requirements

[Azure DevOps Extension for Azure CL](https://github.com/Azure/azure-devops-cli-extension)

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

### Build docker container

```sh
docker build -t azure-devops-backup-repos .
```
