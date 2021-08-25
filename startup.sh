#!/bin/bash
# install azurecli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

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
sudo mkdir /mnt/vmssfileshare
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
