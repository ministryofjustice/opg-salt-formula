{% from "admins/map.jinja" import admins with context %}

include:
  - bootstrap.groups
  - bootstrap.sudo


{% for user, data in admins.iteritems() %}

{% if 'absent' in data and data['absent'] %}
admin-{{ user }}:
  user.absent:
    - name: {{ user }}

{% else %}
admin-{{ user }}:
  user.present:
    - name: {{ user }}
    - home: /home/{{ user }}
    - shell: /bin/bash
    - order: 1
    - groups:
      - wheel
      - supervisor
      - adm
      - root
    - require:
      - group: supervisor
      - group: wheel
  {% for key in data.get("public_keys", []) %}

admin-{{ user}}-key-{{ loop.index0 }}:
  ssh_auth.present:
    - name: {{ key['key'] }}
    - comment: {{ key['comment'] | default('') }}
    - user: {{ user }}
    - enc: {{ key['enc'] | default('ssh-rsa') }}
    - config: .ssh/authorized_keys2
    - order: 1
    - require:
      - user: admin-{{ user }}
  {% else %}
  ssh_auth.present:
    - name: {{ data['key'] }}
    - comment: {{ data['comment'] | default('') }}
    - user: {{ user }}
    - enc: {{ data['enc'] | default('ssh-rsa') }}
    - config: .ssh/authorized_keys2
    - order: 1
    - require:
      - user: admin-{{ user }}
  {% endfor %}

/home/{{ user }}/.bashrc:
  file.append:
    - template: jinja
    - source: salt://admins/templates/bashrc
    - require:
      - user: admin-{{ user }}

  {% if 'use_vim_editing' in data and data['use_vim_editing'] %}
/home/{{ user }}/.inputrc:
  file.managed:
    - contents: 'set editing-mode vi\n'
    - mode: 0644
    - user: {{ user }}
  {% endif %}

# 'duplicity' unfortunately will create this with the wrong owner
# if used with sudo, so make sure it's there with the right owner.
/home/{{ user }}/.gnupg:
  file.directory:
    - mode: 0700
    - user: {{ user }}

{% endif %}

{% endfor %}


