{% set beats = pillar['elastic-beats'] %}
{%- for beat in beats %}
{%-   if 'beat' in beat %}
{{ beat }}:
  service.running:
    - watch:
        - file: /etc/{{ beat }}/{{ beat }}.yml

/etc/{{ beat }}/{{ beat }}.yml:
  file.managed:
    - source: salt://elastic-beats/templates/{{ beat }}.yml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644

{%   endif -%}
{% endfor -%}
