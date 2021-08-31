import os
import json
import requests
import datetime
import hashlib
import hmac
import base64
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--config-id', type=str)
parser.add_argument('--time-in-seconds', type=int)
parser.add_argument('--number-of-instances', type=int)

args = parser.parse_args()

print('----------------------------------------------')
customer_id = os.environ.get("WORKSPACE_ID", 'key placeholder value')
shared_key = os.environ.get("WORKSPACE_KEY", 'key placeholder value')
print(args.time_in_seconds)
print(args.config_id)
print(args.number_of_instances)

print('----------------------------------------------')


# Update the customer ID to your Log Analytics workspace ID
# customer_id = 'xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'

# For the shared key, use either the primary or the secondary Connected Sources client authentication key   
# shared_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# The log type is the name of the event that is being submitted
log_type = 'PerformanceTestVmss'

# An example JSON web monitor object
json_data = [{
   "slot_ID": 12345,
    "ID": "5cdad72f-c848-4df0-8aaa-ffe033e75d57",
    "time_in_seconds": args.time_in_seconds,
    "config_id": args.config_id,
    "number_of_instances": args.number_of_instances,
}]
body = json.dumps(json_data)

#####################
######Functions######  
#####################

# Build the API signature
def build_signature(customer_id, shared_key, date, content_length, method, content_type, resource):
    x_headers = 'x-ms-date:' + date
    string_to_hash = method + "\n" + str(content_length) + "\n" + content_type + "\n" + x_headers + "\n" + resource
    bytes_to_hash = bytes(string_to_hash, encoding="utf-8")  
    decoded_key = base64.b64decode(shared_key)
    encoded_hash = base64.b64encode(hmac.new(decoded_key, bytes_to_hash, digestmod=hashlib.sha256).digest()).decode()
    authorization = "SharedKey {}:{}".format(customer_id,encoded_hash)
    return authorization

# Build and send a request to the POST API
def post_data(customer_id, shared_key, body, log_type):
    method = 'POST'
    content_type = 'application/json'
    resource = '/api/logs'
    rfc1123date = datetime.datetime.utcnow().strftime('%a, %d %b %Y %H:%M:%S GMT')
    content_length = len(body)
    signature = build_signature(customer_id, shared_key, rfc1123date, content_length, method, content_type, resource)
    uri = 'https://' + customer_id + '.ods.opinsights.azure.com' + resource + '?api-version=2016-04-01'

    headers = {
        'content-type': content_type,
        'Authorization': signature,
        'Log-Type': log_type,
        'x-ms-date': rfc1123date
    }

    response = requests.post(uri,data=body, headers=headers)
    if (response.status_code >= 200 and response.status_code <= 299):
        print('Accepted')
    else:
        print("Response code: {}".format(response.status_code))

post_data(customer_id, shared_key, body, log_type)
