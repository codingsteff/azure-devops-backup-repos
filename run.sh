#!/bin/sh

az devops configure --defaults organization=https://dev.azure.com/$AZURE_DEVOPS_EXT_ORG
az devops configure -l

pwsh ./backup-repos.ps1 $AZURE_DEVOPS_EXT_ORG /repos $AZURE_DEVOPS_EXT_PAT
