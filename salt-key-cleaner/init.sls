/var/log/salt:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/usr/local/sbin/salt-key-cleaner:
  file.managed:
    - source: salt://salt-key-cleaner/files/salt-key-cleaner
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: /var/log/salt

# Periodically execute script to clean old keys on the Minion Master.
salt-key-cleaner-cron-job:
  cron.present:
    - name: /usr/local/sbin/salt-key-cleaner >/dev/null 2>&1
    - identifier: Salt Key Cleaner
    - user: root
    - minute: 0
    - hour: '*/4'
    - require:
      - file: /usr/local/sbin/salt-key-cleaner

cron-job-bash-shell-cleaner:
  cron.env_present:
    - name: SHELL
    - value: /bin/bash
    - user: root
    - require:
      - cron: salt-key-cleaner-cron-job
