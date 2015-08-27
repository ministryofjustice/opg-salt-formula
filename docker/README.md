opg-docker-formula
==================
Our simplified way to manage docker using salt and docker-compose.

Exposed state sls:
- docker
- docker-compose
- docker-compose.services

Exposed state module:
- docker_compose


docker sls
----------
Installs docker and configures /root/.dockercfg based on pillar['docker-registries']


docker-compose sls
------------------
Installs docker-compose


docker-compose.services
-----------------------
Based on `pillar.services` and `docker-compose.yml` files it:
- generates `docker-compose.yml` files on each host (if service is in pillar for specific host then it means that container needs to run there)
- generates env file for each running container (data from: `pillar.servies.{{service_name}}.{{app_name}}.env`)
- ensures that expected version of container is pulled to the host (`docker-compose pull`)
- ensures that containers are running (`docker-compose up --no-recreate`)

Example pillar:
```
services:
    front:
        docker-compose-source: salt://service-front/docker-compose.yml
        client:
            env: {}
    admin:
        docker-compose-source: salt://service-admin/docker-compose.yml
        admin:
            env: {}
    backend:
        docker-compose-source: salt://service-backend/docker-compose.yml
        api:
            env: {}
    monitoring-proxy:
        docker-compose-source: salt://monitoring/proxy/templates/docker-compose.yml
        monitoring-proxy:
            env: {}
    monitoring:
        docker-compose-source: salt://monitoring/server/templates/docker-compose.yml
        monitoring:
            env: {}
    monitoring-client:
        docker-compose-source: salt://monitoring/client/templates/docker-compose.yml
        monitoring-client:
            env: {}
```

For each service specified above you need to create a file `service-{{service_name}}/docker-compose.yml` 
and ensure it is available in `base_root`. This file will be passed through template engine in case you want to 
make things dynamic (i.e. keep container tag in piller/grain).


docker_compose state module
---------------------------
This module is used by `docker-compose.services`.

Example usage:
```
my_project_running:
  docker_compose.up:
    - config: /etc/docker-compose/docker-compose-app.yml
    - project: my_project
    - cmd: /opt/bin/docker-compose
```


Q&A
---

Q: What is app/service relation to tag?
A: Each host is tagged with: 
- project
- services


Q: What is service
A: Each service is a separate docker-compose file and a set of env variable files for each app
Later these variables will be feed into `consul`, but for now they reside on host


Q: Example pillar for centralised monitoring
A:
```
services:
    monitoring:
        docker-compose-source: salt://monitoring/server/templates/docker-compose.yml
        monitoring:
            env: {}
    monitoring-client:
        docker-compose-source: salt://monitoring/client/templates/docker-compose.yml
        monitoring-client:
            env: {}
```


Q: What prevents hacked frontend host from getting api secrets?
A: Unless we teach salt-master to verify if querying salt-minion has roles it's claiming - nothing

potential options
1) salt defaults to reading tags from aws api and salt-master audits if minion is presenting with correct role
- or even better salt-master knows minion role based on minion tags/security groups
- security group naming: {{service}}-service
2) pillars in S3 and IAM roles limiting access
3) consul allows for acls. So only when you have been granted permission you will get access to specific keys.
4) etcd acls
