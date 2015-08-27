{#
Use it to disable autostart of init.d services after installation so that you can configure them earlier.

Rocommended way to setup a service is:
- install
- configure
- initialize
- start


Instead of:
- install & start
- configure
- initialize
- try to stop
- kill it
- start
- remove data from 1st start


Formula allows to whitelist specific services by simply creating an empty file like:
touch /etc/policy-rc.d/whitelist/ssh

Or in more salt way
/etc/policy-rc.d/whitelist/ssh:
  file.managed:
    - makedirs: True

#}


policyrcd-script-zg2:
  pkg.installed:
    - order: 0


/etc/zg-policy-rc.d.conf:
  file.managed:
    - source: salt://bootstrap/files/zg-policy-rc.d.conf
    - mode: 755
    - order: 0


/etc/policy-rc.d/whitelist:
  file.directory:
    - mode: 755
    - makedirs: True
    - order: 0


/etc/policy-rc.d/whitelist/ssh:
  file.managed:
    - makedirs: True
    - require:
      - file: /etc/policy-rc.d/whitelist
    - order: 0
