{% from "monitoring/map.jinja" import monitoring with context %}

include:
  - .docker
  - .crontab


monitoring-server-project-dir:
  file.directory:
    - name: /etc/docker-compose/monitoring-server
    - user: root
    - group: root
    - mode: 0755

monitoring-server-project-dir-test:
  file.directory:
    - name: /etc/docker-compose/monitoring-server/chickens
    - user: root
    - group: root
    - mode: 0755

monitoring-server-docker-compose-yml:
  file.managed:
    - name: /etc/docker-compose/monitoring-server/docker-compose.yml
    - source: salt://monitoring/templates/compose-monitoring-server.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 644

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
    - source: salt://monitoring/templates/service.env
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
