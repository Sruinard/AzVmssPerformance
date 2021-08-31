import os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--config-id', type=int)
parser.add_argument('--time-in-seconds', type=int)
parser.add_argument('--number-of-instances', type=int)

args = parser.parse_args()

print(args.config_number)
print('----------------------------------------------')
environment_var = os.environ.get("WORLD", 'this is a placeholder value')
print(environment_var)
environment_var_key = os.environ.get("WORKSPACE_KEY", 'key placeholder value')
print(environment_var_key)
print(args.time_in_seconds)
print(args.config_id)
print(args.number_of_instances)

print('----------------------------------------------')
