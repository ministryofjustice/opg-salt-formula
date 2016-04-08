{% from "monitoring/map.jinja" import monitoring with context %}

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
    - source: salt://monitoring/templates/compose-monitoring-client.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 644

{% for service in salt['pillar.get']('monitoring:client') %}
{% if 'env' in pillar['monitoring']['client'][service]  %}

/etc/docker-compose/monitoring-client/{{service}}.env:
  file.managed:
    - source: salt://monitoring/templates/service.env
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        project: 'client'
        service: {{service}}
    - require:
      - file: monitoring-client-project-dir

{% endif %}
{% endfor %}

