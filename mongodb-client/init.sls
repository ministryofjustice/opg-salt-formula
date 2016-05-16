mongodb-server:
  pkg.purged

mongodb-clients:
  pkg.purged

mongodb-org-apt-key:
  cmd.run:
    - name: apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
    - unless: apt-key list | grep '7F0CEB10'
    - require:
      - pkg: mongodb-server
      - pkg: mongodb-clients

mongodb-org-deb:
  pkgrepo.managed:
    - humanname: Official MongoDB Org Repo
    - name: deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse
    - file: /etc/apt/sources.list.d/mongodb-org.list
    - require:
      - cmd: mongodb-org-apt-key

mongodb-org-shell:
  pkg.installed:
    - version: 3.0.3
    - require:
      - pkgrepo: mongodb-org-shell

mongodb-org-tools:
  pkg.installed:
    - version: 3.0.3
    - require:
      - pkgrepo: mongodb-org-tools