include:
  - .groups

/data:
  file:
    - directory

/srv:
  file:
    - directory


/var/log:
  file:
    - directory

/usr/src/packages:
  file:
    - directory

/var/run/services:
  file:
    - directory
    - user: root
    - group: webservice
    - mode: 770
    - require:
      - group: webservice
