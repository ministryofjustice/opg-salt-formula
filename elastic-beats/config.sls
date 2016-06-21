{% set beats = pillar['monitoring']['beats'] %}
{%- for beat in beats %}
{%-   if 'beat' in beat %}
{{ beat }}:
  service.running:
    - watch:
        - file: /etc/{{ beat }}/{{ beat }}.yml
        - file: /etc/{{ beat }}/{{ beat }}.template.json

/etc/{{ beat }}/{{ beat }}.yml:
  file.managed:
    - source: salt://elastic-beats/templates/{{ beat }}.yml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644

/etc/{{ beat }}/{{ beat }}.template.json:
  file.managed:
    - source: salt://elastic-beats/templates/{{ beat }}.template.json.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644

{%   endif -%}
{% endfor -%}
