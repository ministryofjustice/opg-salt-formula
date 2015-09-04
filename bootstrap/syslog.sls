/etc/rsyslog.d/10-monitoring.conf:
  file.managed:
    - source: salt://bootstrap/files/10-monitoring.conf


rsyslog:
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/rsyslog.d/10-monitoring.conf
