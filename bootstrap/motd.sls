/etc/motd:
  file.touch

motd_quote:
  file.append:
    - name: /etc/motd
    - text: "Role: {{ grains['opg_role'] }}"
