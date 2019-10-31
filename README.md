# Azure DevOps - Backup Repositories

Get all Azure DevOps git repositories with help of git clone or pull

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
.\backup-repositories.ps1 "organization" "/repos" "[personal-access-token]"
```

Personal access token is optional, otherwise it uses system configured git credentials.
