include:
  - .docker

{% if 'monitoring' in pillar %}
{% for service in pillar['monitoring'] %}
{% if 'env' in pillar['monitoring'][service] %}

/etc/docker-compose/{{service}}.env:
  file.managed:
    - source: salt://monitoring/templates/service.env
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        service: {{service}}
    - require:
      - sls: docker-compose

{% endif %}
{% endfor %}
{% endif %}
