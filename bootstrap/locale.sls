generate-locale:
  cmd.run:
    - name: locale-gen en_GB.UTF-8
    - unless: LANG=C egrep -q '(LANG|LC_ALL)=en_GB.UTF-8' /etc/default/locale

update-locale:
  cmd.run:
    - name: update-locale LANG=en_GB.UTF-8 LC_ALL=en_GB.UTF-8
    - unless: LANG=C egrep -q '(LANG|LC_ALL)=en_GB.UTF-8' /etc/default/locale
    - require:
      - cmd: generate-locale
