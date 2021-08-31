import os
print('----------------------------------------------')
environment_var = os.environ.get("WORLD", 'this is a placeholder value')
print(environment_var)
print('----------------------------------------------')
