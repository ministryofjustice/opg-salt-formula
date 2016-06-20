{% from "elastic-beats/map.jinja" import services with context %}
{% if 'beats' in pillar['monitoring'] %}
/var/log/beats:
  file.directory

include:
  - .config
{% endif %}