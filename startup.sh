#!/bin/bash
# install azurecli
# curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
sudo apt-get update
sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg
curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    sudo tee /etc/apt/sources.list.d/azure-cli.list

sudo apt-get update
sudo apt-get install azure-cli

# login with managed identity
az login --identity

# get storage account key
resourceGroupName=vmss-performance
storageAccountName=vmsssaklm
storageAccountKey=$(az storage account keys list \
    --resource-group $resourceGroupName \
    --account-name $storageAccountName \
    --query "[0].value" | tr -d '"')

# make directories and write credentials to file
if [ ! -d "/mnt/vmssfileshare" ]; then
sudo mkdir /mnt/vmssfileshare
fi
if [ ! -d "/etc/smbcredentials" ]; then
sudo mkdir /etc/smbcredentials
fi
if [ ! -f "/etc/smbcredentials/vmsssaklm.cred" ]; then
        sudo bash -c "echo 'username=vmsssaklm' >> /etc/smbcredentials/vmsssaklm.cred"
        sudo bash -c "echo 'password=$storageAccountKey' >> /etc/smbcredentials/vmsssaklm.cred"
fi
# enable read permission
sudo chmod 600 /etc/smbcredentials/vmsssaklm.cred

# mount directory
sudo bash -c 'echo "//vmsssaklm.file.core.windows.net/vmssfileshare /mnt/vmssfileshare cifs nofail,vers=3.0,credentials=/etc/smbcredentials/vmsssaklm.cred,dir_mode=0777,file_mode=0777,serverino" >> /etc/fstab'
sudo mount -t cifs //vmsssaklm.file.core.windows.net/vmssfileshare /mnt/vmssfileshare -o vers=3.0,credentials=/etc/smbcredentials/vmsssaklm.cred,dir_mode=0777,file_mode=0777,serverino


 
#Download AzCopy
wget https://aka.ms/downloadazcopy-v10-linux
 
#Expand Archive
tar -xvf downloadazcopy-v10-linux
 
#(Optional) Remove existing AzCopy version
sudo rm /usr/bin/azcopy
 
#Move AzCopy to the destination you want to store it
sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/


# install jq
sudo apt install jq <<< y

# 
curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | jq
token=$(curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -H Metadata:true | jq -r .access_token)

export WORKSPACE_KEY=$(curl 'https://vmsskeyvaultsr.vault.azure.net/secrets/workspacekey?api-version=2016-10-01' -H "Authorization: Bearer ${token}" | jq -r .value)
export WORKSPACE_ID$(curl 'https://vmsskeyvaultsr.vault.azure.net/secrets/workspaceid?api-version=2016-10-01' -H "Authorization: Bearer ${token}" | jq -r .value)