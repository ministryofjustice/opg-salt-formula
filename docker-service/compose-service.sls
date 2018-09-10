include:
  - docker

/etc/docker-compose:
  file.directory

{% for service_name in pillar['services'] %}
{%   if pillar['services'][service_name]['type'] | default('compose') == 'compose' %}
{%     set initscript = pillar['services'][service_name]['initscript'] | default('yes') %}
/etc/docker-compose/{{service_name}}:
  file.directory:
    - user: root
    - group: root
    - mode: 0755

{%     if 'directories' in pillar['services'][service_name] %}
{%       for directory in pillar['services'][service_name]['directories'] %}

{{ pillar['services'][service_name]['directories'][directory]['path']}}:
  file.directory:
    - user:  {{ pillar['services'][service_name]['directories'][directory]['user'] | default('root') }}
    - group: {{ pillar['services'][service_name]['directories'][directory]['group'] | default('root') }}
    - mode:  {{ pillar['services'][service_name]['directories'][directory]['mode'] | default('0755') }}

{%       endfor %}
{%     endif %}

/etc/docker-compose/{{service_name}}/docker-compose.yml:
  file.managed:
    - source: {{pillar['services'][service_name]['docker-compose-source']}}
    - template: jinja
    - user: root
    - group: root
    - mode: 644
{%     if initscript == 'yes' %}
/etc/init.d/docker-compose-{{service_name}}:
  file.managed:
    - source: salt://docker-service/templates/docker-compose-service
    - template: jinja
    - user: root
    - group: root
    - mode: 755
    - context:
        service_name: {{service_name}}

docker-compose-{{service_name}}:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: /etc/init.d/docker-compose-{{service_name}}
      
# hack for 16.04 whose systemd status can be 'active (exited)' which salt (wrongly) believes is running
service docker-compose-{{service_name}} start:
  cmd.run:
    - require:
      - service: docker-compose-{{service_name}}
     
{%     endif %}

{%     if pillar['services'][service_name]['env_files'] is defined %}
{%       for env_name in pillar['services'][service_name]['env_files'] %}
{%         set env_extra_test = env_name + '_' + grains['opg_role'] %}
{%         if pillar['services'][service_name]['extra'] is defined and pillar['services'][service_name]['extra'][env_extra_test] is defined %}
{%           set env_extra = env_extra_test %}
{%         endif %}
/etc/docker-compose/{{service_name}}/{{env_name}}.env:
  file.managed:
    - source: salt://docker-service/templates/app.env
    - template: jinja
    - user: root
    - group: root
    - mode: 600
    - context:
        app_name: {{env_name}}
        service_name: {{service_name}}
{%       if env_extra is defined %}
        env_extra: {{env_extra}}
{%       endif %}
{%       if initscript == 'yes' %}
    - watch_in:
      - service: docker-compose-{{service_name}}
{%       endif %}
{%       endfor %}
{%     else %}
{%       for app_name in pillar['services'][service_name] %}
{%         if 'env' in pillar['services'][service_name][app_name] %}

/etc/docker-compose/{{service_name}}/{{app_name}}.env:
  file.managed:
    - source: salt://docker-service/templates/app.env
    - template: jinja
    - user: root
    - group: root
    - mode: 600
    - context:
        app_name: {{app_name}}
        service_name: {{service_name}}
{%       if initscript == 'yes' %}
    - watch_in:
      - service: docker-compose-{{service_name}}
{%       endif %}

{%         endif %}
{%       endfor %}
{%     endif %}
{%   endif %}

# We have an extra section that adds role specific config to an environment file, there are cases whereby
# this environment file has no common info so will not be created in the env_files section, this below handles this
# edge case
{%  if pillar['services'][service_name]['extra'] is defined %}
{%    for env_file in pillar['services'][service_name]['extra'] %}
# Does the env file belong to the role, normally it is named envfile_<rolename>
{%      if grains['opg_role'] in env_file %}
# Check we haven't written it out already, if we have, it means it existed in the env_files section and we would overwrite
# the contents
{%        if env_file|replace('_' + grains['opg_role'], '') not in pillar['services'][service_name]['env_files'] %}
# Keep our names sane please
{%          set env_filename = env_file|replace('_' + grains['opg_role'], '') %}
/etc/docker-compose/{{service_name}}/{{env_filename}}.env:
  file.managed:
    - source: salt://docker-service/templates/app.env
    - template: jinja
    - user: root
    - group: root
    - mode: 600
    - context:
        app_name: {{env_filename}}
        service_name: {{service_name}}
# We need the data from the full role_envfile path in yaml
        env_extra: {{env_file}}
{%       if initscript == 'yes' %}
    - watch_in:
      - service: docker-compose-{{service_name}}
{%       endif %}
{%        endif %}
{%      endif %}
{%    endfor %}
{%  endif %}

{% endfor %}
