resourceGroupName=vmss-performance
storageAccountName=vmsssaklm

az vmss extension set \
    --publisher Microsoft.Azure.Extensions \
    --version 2.0 \
    --name CustomScript \
    --vmss-name vmss-instance \
    --resource-group vmss-performance \
    --settings "{\"fileUris\":[\"https://raw.githubusercontent.com/Sruinard/AzVmssPerformance/master/echo_env_var.py\", \"https://raw.githubusercontent.com/Sruinard/AzVmssPerformance/master/run_logging_extension.sh\"],\"commandToExecute\":\"./run_logging_extension.sh $1 $2\"}"
