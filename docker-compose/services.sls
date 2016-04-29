include:
  - docker
  - docker-compose

{%  if 'services' in pillar %}
{%    for service_name in pillar['services'] %}
/etc/docker-compose/{{service_name}}:
  file.directory:
    - user: root
    - group: root
    - mode: 0755

{%      if 'directories' in pillar['services'][service_name] %}
{%        for directory in pillar['services'][service_name]['directories'] %}

{{ pillar['services'][service_name]['directories'][directory]['path']}}:
  file.directory:
    - user:  {{ pillar['services'][service_name]['directories'][directory]['user'] | default('root') }}
    - group: {{ pillar['services'][service_name]['directories'][directory]['group'] | default('root') }}
    - mode:  {{ pillar['services'][service_name]['directories'][directory]['mode'] | default('0755') }}

{%        endfor %}
{%      endif %}

/etc/docker-compose/{{service_name}}/docker-compose.yml:
  file.managed:
    - source: {{pillar['services'][service_name]['docker-compose-source']}}
    - template: jinja
    - user: root
    - group: root
    - mode: 644


/etc/init.d/docker-compose-{{service_name}}:
  file.managed:
    - source: salt://docker-compose/templates/docker-compose-service
    - template: jinja
    - user: root
    - group: root
    - mode: 755
    - context:
        service_name: {{service_name}}


docker-compose-{{service_name}}:
  service.running:
    - enable: True
    - watch:
      - file: /etc/init.d/docker-compose-{{service_name}}


{%      if pillar['services'][service_name]['env_files'] is defined %}
{%        for env_name in pillar['services'][service_name]['env_files'] %}
{%          set env_extra_test = env_name + '_' + grains['opg_role'] %}
{%          if pillar['services'][service_name]['extra'][env_extra_test] is defined %}
{%            set env_extra = env_extra_test %}
{%          endif %}
/etc/docker-compose/{{service_name}}/{{env_name}}.env:
  file.managed:
    - source: salt://docker-compose/templates/app.env
    - template: jinja
    - user: root
    - group: root
    - mode: 600
    - context:
        app_name: {{env_name}}
        service_name: {{service_name}}
{% if env_extra is defined %}
        env_extra: {{env_extra}}
{% endif %}
    - watch_in:
      - service: docker-compose-{{service_name}}

{%        endfor %}
{%      else %}
{%        for app_name in pillar['services'][service_name] %}
{%          if 'env' in pillar['services'][service_name][app_name] %}

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
    - watch_in:
      - service: docker-compose-{{service_name}}

{%          endif %}
{%        endfor %}
{%      endif %}
{%    endfor %}
{%  endif %}
