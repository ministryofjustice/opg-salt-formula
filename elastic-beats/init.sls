{% from "elastic-beats/map.jinja" import beats with context %}
{% if 'elastic-beats' in salt['pillar.get']() %}
/var/log/beats:
  file.directory

include:
  - .config
{% endif %}