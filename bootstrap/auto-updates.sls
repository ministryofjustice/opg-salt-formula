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
    - require:
      - pkg: unattended-upgrades

/etc/apt/apt.conf.d/20auto-upgrades:
  file:
    - managed
    - source: salt://bootstrap/templates/auto-upgrades
    - mode: 440
    - template: jinja
    - require:
      - pkg: unattended-upgrades

apticron:
  pkg:
    - installed

/etc/apticron/apticron.conf:
  file:
    - managed
    - source: salt://bootstrap/templates/apticron.conf
    - mode: 440
    - template: jinja
    - require:
      - pkg: apticron
