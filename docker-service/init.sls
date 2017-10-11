{% from "docker-service/map.jinja" import services with context %}
{% if 'services' in pillar %}
include:
  - .compose-service
{% endif %}

