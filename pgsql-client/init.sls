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

{%- set pg_root = salt['pillar.get']('services:front:test:env', []) %}
pgsql-environment:
  file.append:
    - name: ~/.bashrc
    - text:
        - export PGDATABASE={{ pg_root.API_DATABASE_NAME }}
        - export PGUSER={{ pg_root.API_DATABASE_USERNAME }}
        - export PGHOST={{ pg_root.API_DATABASE_HOSTNAME }}