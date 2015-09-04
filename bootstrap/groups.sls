ssh_user:
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
