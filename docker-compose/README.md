# docker-compose-formula
Saltstack formula for managing docker compose services and supporting directories via pillar data

This formula supports both single environment files and an array of env files per service

## Sample Pillar Data - Single env file, No directories ##

```yml
services:
  admin-tasks:
    docker-compose-source: salt://service-master/templates/docker-compose.yml
    scripts:
      env:
        MONITORING_ENABLED: True
        OPG_SERVICE: scripts
        EBS_SNAPSHOT_RETENTION_DAYS: 8
        EBS_SNAPSHOT_MONITOR_HOST: monitoring
        EBS_SNAPSHOT_MONITOR_PORT: 2003
```

## Sample Pillar Data - Directory creation ##

```yml
services:
  monitoring-server:
    docker-compose-source: salt://monitoring/templates/compose-monitoring-server.yml
    directories:
      grafana:
        path: /data/grafana
        mode: 0775
        user: foo
        group: bar
      graphite:
        path: /data/graphite
        mode: 0775
      elasticsearch:
        path: /data/elasticsearch
```

The `mode`, `user` and `group` key all have sensible defaults of  `root, root and 0755` respectively

Where pillar data exists, the following values MUST be specified as default values cannot be derived:

* path

## Sample Pillar Data - Multiple env files for one service ##

```yml
services:
  monitoring-client:
    docker-compose-source: salt://monitoring/templates/compose-monitoring-client.yml
    #Common settings for all clients
    env_files:
      sensuclient:
       #Common variables
      checksbase:
        #Common variables
    #Grain specific settings
    extra:
      checksbase_master:
        #grain specific variables
      checksbase_monitoring:
        #grain specific variables
```

The names under the `extra` section are simply `env_file_name`_`grain`.