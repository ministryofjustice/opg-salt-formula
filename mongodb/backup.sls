s3cmd:
  pip.installed:
    - require:
      - pkg: python-pip

/usr/local/bin/mongo_s3_backup:
  file.managed:
    - source: salt://mongodb/files/mongo_s3_backup
    - mode: 774
    - user: root
    - group: root

/data/mongodbackup/:
  file.directory:
    - mode: 660
    - user: root
    - group: root

{% set nodename = salt['grains.get']('nodename', '') %}
{% set opg_environment = salt['grains.get']('opg_environment', '') %}
{% if nodename == 'mongodb-03' %}
/usr/local/bin/mongo_s3_backup admin {{ pillar['mongodb_admin_password']}} eu-west-1 opg-lpa-backup-{{ opg_environment }} >> /var/log/mongo_s3_backup.log:
  cron.present:
    - identifier: MONGO_BACKUP
    - user: root
    - minute: '*/60'
    - set_env: root MAILTO user@example.com
{% endif %}
