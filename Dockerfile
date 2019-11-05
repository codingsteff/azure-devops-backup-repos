FROM mcr.microsoft.com/powershell

# Install prerequisites
RUN apt-get update && apt-get install -y \
    curl \
    git

# Install Azure CLI
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Azure CLI DevOps Extension
# https://github.com/Azure/azure-devops-cli-extension
RUN az extension add --name azure-devops

COPY backup-repos.ps1 /

COPY run.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run.sh 
CMD ["run.sh"]