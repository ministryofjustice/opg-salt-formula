webservice:
  group:
    - present
    - system: True

# nginx uses this group to publish files
www-data:
  group:
    - present
    - system: True

ssh_user:
  group:
    - present
    - system: True

#can configure supervior
supervisor:
  group:
    - present
    - system: True

#can sudo
wheel:
  group:
    - present
    - system: True

#can sudo
sudo:
  group:
    - present
    - system: True
