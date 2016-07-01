{% from "elastic-beats/map.jinja" import beats with context %}
{% if 'elastic-beats' in pillar %}
/var/log/beats:
  file.directory

include:
  - .config
{% endif %}