curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

az login --identity

resourceGroupName=vmss-performance
storageAccountName=vmsssaklm
storageAccountKey=$(az storage account keys list \
    --resource-group $resourceGroupName \
    --account-name $storageAccountName \
    --query "[0].value" | tr -d '"')


sudo mount -t cifs //vmsssaklm.file.core.windows.net/vmssfileshare /mnt/vmssfileshare -o vers=3.0,credentials='password=${storageAccountKey}'

