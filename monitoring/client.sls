{% from "opg-docker-monitoring/map.jinja" import monitoring with context %}

include:
  - .docker

monitoring-client-project-dir:
  file.directory:
    - name: /etc/docker-compose/monitoring-client
    - user: root
    - group: root
    - mode: 0755


monitoring-client-docker-compose-yml:
  file.managed:
    - name: /etc/docker-compose/monitoring-client/docker-compose.yml
    - source: salt://opg-docker-monitoring/templates/compose-monitoring-client.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 644


/etc/init.d/docker-compose-monitoringclient:
  file.managed:
    - name: docker-compose-monitoringclient
    - source: salt://docker-compose/templates/docker-compose-service
    - template: jinja
    - user: root
    - group: root
    - mode: 755
    - context:
        service_name: monitoringclient

docker-compose-monitoringclient:
  service.running:
    - enable: True
    - watch:
      - file: /etc/init.d/docker-compose-monitoringclient

{% for service in salt['pillar.get']('monitoring:client') %}
{% if 'env' in pillar['monitoring']['client'][service]  %}

/etc/docker-compose/monitoring-client/{{service}}.env:
  file.managed:
    - source: salt://opg-docker-monitoring/templates/service.env
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        project: 'client'
        service: {{service}}
    - watch_in:
      - service: docker-compose-{{service}}
    - require:
      - file: monitoring-client-project-dir

{% endif %}
{% endfor %}

