
/etc/sudoers:
  file:
    - managed
    - source: salt://bootstrap/templates/sudoers
    - mode: 440
    - template: jinja
    - order: 1

