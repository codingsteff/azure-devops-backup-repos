# Azure DevOps - Backup Repositories

Get all Azure DevOps git repositories with help of git clone or pull

## Requirements

[Azure DevOps Extension for Azure CL](https://github.com/Azure/azure-devops-cli-extension)

    # login interactive
    az login

    # login with Personal Access Token
    az devops login --organization https://dev.azure.com/[ORGANIZATION]

## Usage

     .\backup-repositories.ps1 "organization" "c:\repos"
