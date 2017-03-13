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

{%- set pg_root = salt['pillar.get']('services:front:test:env', []) -%}
pgsql-environment:
  environ.setenv:
     - name: env_for_pgsql
     - update_minion: True
     - value:
         PGDATABASE: {{ pg_root.API_DATABASE_NAME }}
         PGUSER: {{ pg_root.API_DATABASE_USERNAME }}
         PGHOST: {{ pg_root.API_DATABASE_HOSTNAME }}