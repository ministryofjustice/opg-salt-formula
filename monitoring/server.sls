{% from "opg-docker-monitoring/map.jinja" import monitoring with context %}

include:
  - .docker
  - .crontab


monitoring-server-project-dir:
  file.directory:
    - name: /etc/docker-compose/monitoring-server
    - user: root
    - group: root
    - mode: 0755


monitoring-server-docker-compose-yml:
  file.managed:
    - name: /etc/docker-compose/monitoring-server/docker-compose.yml
    - source: salt://opg-docker-monitoring/templates/compose-monitoring-server.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 644


monitoring-server-docker-adhoc-yml:
  file.managed:
    - name: /etc/docker-compose/monitoring-server/docker-compose-adhoc.yml
    - source: salt://opg-docker-monitoring/templates/compose-monitoring-adhoc.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 644

/etc/init.d/docker-compose-monitoringserver:
  file.managed:
    - name: docker-compose-monitoringserver
    - source: salt://docker-compose/templates/docker-compose-service
    - template: jinja
    - user: root
    - group: root
    - mode: 755
    - context:
        service_name: monitoringserver
    - require:
      - file: monitoring-server-docker-compose-yml
      - file: grafana-data-dir
      - file: graphite-data-dir
      - file: elasticsearch-data-dir

docker-compose-monitoringserver:
  service.running:
    - enable: True
    - watch:
      - file: /etc/init.d/docker-compose-monitoringserver


grafana-data-dir:
  file.directory:
    - name: {{ monitoring.server.grafana.data_dir }}
    - mode: 0777
    - makedirs: True


graphite-data-dir:
  file.directory:
    - name: {{ monitoring.server.graphite.data_dir }}
    - mode: 0777
    - makedirs: True


elasticsearch-data-dir:
  file.directory:
    - name: {{ monitoring.server.elasticsearch.data_dir }}
    - mode: 0777
    - makedirs: True


{% for service in salt['pillar.get']('monitoring:server') %}
{% if 'env' in pillar['monitoring']['server'][service]  %}

/etc/docker-compose/monitoring-server/{{service}}.env:
  file.managed:
    - source: salt://opg-docker-monitoring/templates/service.env
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        project: 'server'
        service: {{service}}
    - require:
      - file: monitoring-server-project-dir

{% endif %}
{% endfor %}


flush_monitoring_udp_conntrack:
  cmd.wait:
    - name: conntrack -D -p udp
