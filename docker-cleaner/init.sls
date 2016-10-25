/usr/local/sbin/docker-image-cleaner:
  file.managed:
    - source: salt://docker-cleaner/files/clean-docker-images
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: /var/log/syslog

# Periodically execute script to clean old keys on the Minion Master.
docker-image-cleaner-cron-job:
  cron.present:
    - name: /usr/local/sbin/clean-docker-images >/dev/null 2>&1
    - identifier: Docker housekeeping
    - user: root
    - minute: 0
    - hour: 1
    - require:
      - file: /usr/local/sbin/docker-image-cleaner
