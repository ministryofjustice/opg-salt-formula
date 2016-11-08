# Periodically execute script to clean old keys on the Minion Master.
salt-key-cleaner-cron-job:
  cron.present:
    - name: salt-run manage.down removekeys=True >/dev/null 2>&1
    - identifier: Salt Key Cleaner
    - user: root
    - minute: 0
    - hour: '*/4'

