/etc/motd:
  file.touch

motd_quote:
  file.append:
    - name: /etc/motd
    - text: "Roles: {{ grains['roles'] }}"
