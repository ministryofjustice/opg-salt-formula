mongodb-server:
  pkg.purged

mongodb-clients:
  pkg.purged

mongodb-org-apt-key:
  cmd.run:
    - name: apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
    - unless: apt-key list | grep '7F0CEB10'

mongodb-org-deb:
  pkgrepo.managed:
    - humanname: Official MongoDB Org Repo
    - name: deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse
    - file: /etc/apt/sources.list.d/mongodb-org.list
    - require:
      - cmd: mongodb-org-apt-key

mongodb-org-shell:
  pkg:
    - refresh: True
    - installed
    - require:
      - pkgrepo: mongodb-org-deb

mongodb-org-tools:
  pkg:
    - installed
    - require:
      - pkgrepo: mongodb-org-deb