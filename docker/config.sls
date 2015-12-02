{% from 'docker/map.jinja' import docker with context %}

/root/.dockercfg:
  file.managed:
    - source: salt://docker/templates/dockercfg
    - mode: 0600
    - user: root
    - group: root
    - template: jinja


{% if docker.manage_config == 'true' %}
/etc/default/docker:
  file.managed:
    - source: salt://docker/templates/docker
    - mode: 0644
    - user: root
    - group: root
    - template: jinja
    - listen_in:
      - service: docker
{% endif %}


{% if docker.tls.ca %}
docker_tls_ca_cert:
  file.managed:
    - name: {{ docker.docker_opts.tls_ca_cert }}
    - source: salt://docker/templates/ca.pem
    - mode: 0600
    - user: root
    - group: root
    - template: jinja
    - listen_in:
      - service: docker
{% endif %}


{% if docker.tls.cert %}
docker_tls_cert:
  file.managed:
    - name: {{ docker.docker_opts.tls_cert }}
    - source: salt://docker/templates/cert.pem
    - mode: 0600
    - user: root
    - group: root
    - template: jinja
    - listen_in:
      - service: docker
{% endif %}



{% if docker.tls.key %}
docker_tls_key:
  file.managed:
    - name: {{ docker.docker_opts.tls_key }}
    - source: salt://docker/templates/key.pem
    - mode: 0600
    - user: root
    - group: root
    - template: jinja
    - listen_in:
      - service: docker
{% endif %}


docker:
  service.running:
    - enable: True
    - reload: True
