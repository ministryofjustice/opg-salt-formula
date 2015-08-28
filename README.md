# opg-salt-formula
Set of salt formulas used in OPG across all projects

All modules are included using `base/init.sls`
So in 99% of cases your `top.sls` should look line:

```
base:
  '*':
    - base
    - opg-docker-monitoring.client
    - opg-collectd
    - hardening

  'opg-role:monitoring':
    - match: grain
    - opg-docker-monitoring.server
```



future
------
migrate:
- opg-docker-monitoring.client
- opg-collectd
