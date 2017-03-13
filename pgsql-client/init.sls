pgsql-client:
  pkg.installed:
    - pkgs:
      - postgresql-client-9.3
      - refresh: True

/root/.pgpass:
  file.managed:
    - source: salt://pgsql-client/templates/pgpass.jinja
    - mode: 0600
    - user: root
    - group: root
    - template: jinja
