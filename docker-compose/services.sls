include:
  - docker
  - docker-compose

{% if 'services' in pillar %}
{% for service_name in pillar['services'] %}
/etc/docker-compose/{{service_name}}:
  file.directory:
    - user: root
    - group: root
    - mode: 0755


/etc/docker-compose/{{service_name}}/docker-compose.yml:
  file.managed:
    - source: {{pillar['services'][service_name]['docker-compose-source']}}
    - template: jinja
    - user: root
    - group: root
    - mode: 644


docker-compose-up-{{service_name}}:
  docker_compose.up:
    - project: {{service_name}}
    - config: /etc/docker-compose/{{service_name}}/docker-compose.yml
    - env:
      - HOME: /root
    - watch:
      - file: /etc/docker-compose/{{service_name}}/*


{% for app_name in pillar['services'][service_name] %}
{% if 'env' in pillar['services'][service_name][app_name] %}
/etc/docker-compose/{{service_name}}/{{app_name}}.env:
  file.managed:
    - source: salt://docker-compose/templates/app.env
    - template: jinja
    - user: root
    - group: root
    - mode: 600
    - context:
        app_name: {{app_name}}
        service_name: {{service_name}}
{% endif %}
{% endfor %}


{% endfor %}
{% endif %}
