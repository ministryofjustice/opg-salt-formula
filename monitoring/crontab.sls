{% from "monitoring/map.jinja" import monitoring with context %}

{% if monitoring.server.elasticsearch.curator.enabled %}

{% for index in monitoring['server']['elasticsearch']['curator']['indices'] %}
elasticsearch-curator-present-delete-{{index}}:
  cron.present:
    - name: "docker-compose -p monitoringserver -f /etc/docker-compose/monitoring-server/docker-compose-adhoc.yml run elasticcurator curator --host {{ monitoring['server']['elasticsearch']['curator']['indices'][index]['host'] }} delete indices {{ monitoring['server']['elasticsearch']['curator']['indices'][index]['options'] }}"
    - identifier: elasticsearch-curator-cron-delete-{{index}}
    - user: root
    - hour: '3'
    - minute: random
{% endfor %}

{% else %}

{% for index in monitoring['server']['elasticsearch']['curator']['indices'] %}
elasticsearch-curator-absent-delete-{{index}}:
  cron.absent:
    - identifier: elasticsearch-curator-cron-delete-{{index}}
    - user: root
{% endfor %}

{% endif %}

{% if monitoring.server.elasticsearch.snapshot.enabled %}
elasticsearch-curator-present-snapshot:
   cron.present:
    - name: "docker-compose -p monitoringserver -f /etc/docker-compose/monitoring-server/docker-compose-adhoc.yml run elasticcurator /scripts/elasticsearch/snapshot_elastic.sh"
    - identifier: elasticsearch-curator-cron-snapshot
    - user: root
    - hour: '2'
    - minute: random

{% else %}

elasticsearch-curator-absent-snapshot:
  cron.absent:
    - identifier: elasticsearch-curator-cron-snapshot
    - user: root

{% endif %}
