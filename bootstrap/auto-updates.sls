---

unattended-upgrades:
  pkg:
    - installed

/etc/apt/apt.conf.d/50unattended-upgrades:
  file:
    - managed
    - source: salt://bootstrap/templates/unattended-upgrades
    - mode: 440
    - template: jinja
    - order: 1

/etc/apt/apt.conf.d/20auto-upgrades:
  file:
    - managed
    - source: salt://bootstrap/templates/20auto-upgrades
    - mode: 440
    - template: jinja
    - order: 1

apticron:
  pkg:
    - installed

/etc/apticron/apticron.conf:
  file:
    - managed
    - source: salt://bootstrap/templates/apticron.conf
    - mode: 440
    - template: jinja
    - order: 1
