# import requests
# import json

# email='kris.nackaerts@edinsights.no'
# password='lynxvision'

# cube_id='cube-42377cfc-8e11-43ca-9e11-0f5d8f9b77d9'
# mask_id='mask-xgpjwfrj'
# project_id='project-90cc4601-a809-446f-98a5-fe33d709a849'


# auth_payload = {'username' : email, 'password' : password}
# url = 'https://maps.edinsights.no/v2/users/token'

# r=requests.post(url, data=auth_payload)
# print(r)
# print(r.json());


import requests
import json

email='kris.nackaerts@edinsights.no'
password='lynxvision'

cube_id='cube-42377cfc-8e11-43ca-9e11-0f5d8f9b77d9'
mask_id='mask-xgpjwfrj'
project_id='project-90cc4601-a809-446f-98a5-fe33d709a849'

url = 'https://maps.edinsights.no/v2/users/token?email=%s&password=%s&access_token=public' % (email,password)

r=requests.get(url)
access_token=r.json()['access_token']

# prints access token
print(access_token)