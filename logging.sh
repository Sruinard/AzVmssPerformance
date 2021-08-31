# parameters:
# $1: configuration id which can be mapped to vm-sku, storage_type and storage_sku
# $2: number of instances currently running


# if fileshare ....
# cp path_to_mount localdir
# elif blockblob ...
# sudo azcopy copy azfilepath+sastoken localdir
time_in_seconds=100

# get workspace keys and export as environment vars
curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | jq
token=$(curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -H Metadata:true | jq -r .access_token)

export WORKSPACE_KEY=$(curl 'https://vmsskeyvaultsr.vault.azure.net/secrets/workspacekey?api-version=2016-10-01' -H "Authorization: Bearer ${token}" | jq -r .value)
export WORKSPACE_ID=$(curl 'https://vmsskeyvaultsr.vault.azure.net/secrets/workspaceid?api-version=2016-10-01' -H "Authorization: Bearer ${token}" | jq -r .value)

# run logging script and write results to log analytics
python3 ./echo_env_var.py --config-id $1 --number-of-instances $2 --time-in-seconds $time_in_seconds 