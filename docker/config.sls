/root/.dockercfg:
  file.managed:
    - source: salt://docker/templates/dockercfg
    - mode: 0600
    - user: root
    - group: root
    - template: jinja


docker:
  service.running
