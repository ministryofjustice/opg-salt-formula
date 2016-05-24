{% from "docker-service/map.jinja" import services with context %}
include:
{% if 'services' in pillar %}
  - .compose-service
{% endif %}

