{% from "docker-service/map.jinja" import services with context %}

{% if 'services' in pillar %}
  - .compose-service
  - .ecs-service
{% endif %}

