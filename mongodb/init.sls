{% from 'mongodb/map.jinja' import mongodb with context %}

include:
  - .backup

install-tls-dependencies:
  pkg.installed:
    - name: python-openssl

mongodb-server:
  pkg.purged

mongodb-clients:
  pkg.purged

mongodb-org-apt-key:
  cmd.run:
    - name: apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
    - unless: apt-key list | grep '7F0CEB10'
    - require:
      - pkg: mongodb-server
      - pkg: mongodb-clients

mongodb-org-deb:
  pkgrepo.managed:
    - humanname: Official MongoDB Org Repo
    - name: deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse
    - file: /etc/apt/sources.list.d/mongodb-org.list
    - require:
      - cmd: mongodb-org-apt-key

mongodb-org:
  pkg.installed:
    - version: 3.0.3
    - require:
      - pkgrepo: mongodb-org-deb

/usr/local/bin/mongo_preconfigure_mongodb_database:
  file.managed:
    - mode: 755
    - user: root
    - group: root
    - source: salt://mongodb/files/mongo_preconfigure_mongodb_database

preconfigure-mongodb-database:
  cmd.run:
    {% if 'mongodb_admin_password' in pillar %}
    - name: "/usr/local/bin/mongo_preconfigure_mongodb_database {{mongodb.dbpath}} {{ pillar['mongodb_admin_password']}}"
    {% else %}
    - name: "/usr/local/bin/mongo_preconfigure_mongodb_database {{mongodb.dbpath}}"
    {% endif %}
    - unless: test -f {{mongodb.dbpath}}/DB_IS_CONFIGURED
    - require:
      - pkg: mongodb-org
      - file: /usr/local/bin/mongo_preconfigure_mongodb_database
      - file: {{mongodb.dbpath}}
    - watch_in:
      - service: mongod

mongod:
  service.running:
    - name: mongod
    - enable: True
    - require:
      - cmd: preconfigure-mongodb-database
      - file: {{mongodb.dbpath}}
    - watch:
      - file: /etc/mongod.conf
      - file: /etc/mongo.pem

/etc/mongo.pem:
  file.managed:
    - contents_pillar: mongodb:pem
    - mode: 600
    - user: mongodb
    - watch_in:
      - service: mongod

/etc/mongod.conf:
  file:
    - managed
    - source: salt://mongodb/templates/mongod.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: preconfigure-mongodb-database

{{mongodb.dbpath}}:
  file.directory:
    - user: mongodb
    - group: mongodb
    - mode: 750
    - makedirs: True
    - require:
      - pkg: mongodb-org

{% if mongodb.key_string %}
/etc/mongodb.key:
  file.managed:
   - user: mongodb
   - group: mongodb
   - mode: 600
   - contents_pillar: mongodb:key_string
{% endif %}

/usr/local/bin/mongo_initiate_replica_set:
  file.managed:
    - user: root
    - group: root
    - mode: 755
    - source: salt://mongodb/files/mongo_initiate_replica_set

/usr/local/bin/mongo_reindex_database:
  file.managed:
    - user: root
    - group: root
    - mode: 755
    - source: salt://mongodb/files/mongo_reindex_database

/usr/local/bin/mongo_restore_database:
  file.managed:
    - user: root
    - group: root
    - mode: 755
    - source: salt://mongodb/files/mongo_restore_database

/usr/local/bin/mongo_create_user:
  file.managed:
    - user: root
    - group: root
    - mode: 755
    - source: salt://mongodb/files/mongo_create_user

/usr/local/bin/create_mongo_user:
  file.absent

/usr/local/bin/restore_mongo_database:
  file.absent

/usr/local/bin/reindex_mongo_database:
  file.absent

/usr/local/bin/initiate_replica_set:
  file.absent

/usr/local/bin/preconfigure_mongodb_database:
  file.absent

{% if mongodb.configuration.auto_initiate_replica_set_params %}
auto_initiate_replica_set:
  cmd.run:
    {% if 'mongodb_admin_password' in pillar %}
    - name: "mongo_initiate_replica_set -u admin -p {{ pillar['mongodb_admin_password'] }} {{ mongodb.configuration.auto_initiate_replica_set_params }}"
    {% else %}
    - name: "mongo_initiate_replica_set {{ mongodb.configuration.auto_initiate_replica_set_params }}"
    {% endif %}
    - require:
      - service: mongod
      - file: /usr/local/bin/mongo_create_user
{% endif %}

{% for dbname, db_def in mongodb.configuration.databases.iteritems() %}
{{ db_def.owner_user }}_on_{{ dbname }}:
  cmd.run:
    {% if 'mongodb_admin_password' in pillar %}
    - name: "mongo_create_user -u admin -p {{ pillar['mongodb_admin_password'] }} {{ dbname }} {{ db_def.owner_user }} {{ db_def.owner_password }}"
    {% else %}
    - name: "mongo_create_user {{ dbname }} {{ db_def.owner_user }} {{ db_def.owner_password }}"
    {% endif %}
    - require:
      - service: mongod
      - file: /usr/local/bin/mongo_create_user
{% if mongodb.configuration.auto_initiate_replica_set_params %}
      - cmd: auto_initiate_replica_set
{% endif %}

{% endfor %}

{% for dbname, db_def in mongodb.configuration.databases.iteritems() %}
{%   for coll_def in db_def.collections %}
{%     for index_def in coll_def.indexes %}
create_index_{{ dbname }}__{{coll_def.name}}__{{index_def.name}}:
  cmd.run:
    - name: "mongo_reindex_database -u {{db_def.owner_user}} -p {{ db_def.owner_password }} {{ dbname }} {{ coll_def.name }} '{{ index_def.key }}'"
    - require:
      - file: /usr/local/bin/mongo_reindex_database
      - cmd: {{ db_def.owner_user }}_on_{{ dbname }}
{%     endfor %}
{%   endfor %}
{% endfor %}

# pymongo is required for the main mongodb sensu check
#python-pymongo:
#  pkg:
#    - installed

/etc/backup.d/30.mongodb:
  file:
    - managed
    - user: root
    - group: root
    - mode: 600
    - source: salt://mongodb/templates/backupninja.mongodb
    - template: jinja
    - onlyif: test -d /etc/backup.d

