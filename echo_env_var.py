import os
print('----------------------------------------------')
environment_var = os.environ.get("WORLD", 'this is a placeholder value')
print(environment_var)
environment_var_key = os.environ.get("WORKSPACE_KEY", 'key placeholder value')
print(environment_var_key)
print('----------------------------------------------')
