{% from "ecs/map.jinja" import config with context -%}

{% for dir in config.agent_dirs %}
{{ dir }}:
  file.directory:
    - makedirs: True

{%- endfor %}

{{ config.nfs_pkg }}:
  pkg.installed

/etc/default/nfs-common:
  file.managed:
    - source: salt://files/nfs-common
    - user: root
    - group: root
    - mode: 0644
    - template: jinja

rpcbind:
  service.started

net.ipv4.conf.all.route_localnet:
    sysctl.present:
      - value: 1

ecs-dnat:
  iptables.append:
    - table: nat
    - chain: PREROUTING
    - jump: DNAT
    - destination: 169.254.170.2
    - dport: 80
    - to-destination: "127.0.0.1:51679"
    - protocol: tcp
    - save: True

ecs-redirect:
  iptables.append:
    - table: nat
    - chain: PREROUTING
    - jump: REDIRECT
    - destination: 169.254.170.2
    - dport: 80
    - to-ports: 51679
    - protocol: tcp
    - save: True

/nfsdata:
  mount.mounted:
    - device: nfs-01:/data
    - fstype: nfs
    - mkmnt: True
    - persist: True
    - opts: _netdev,soft,intr,rsize=1048576,wsize=1048576

