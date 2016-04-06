## Deploy this SLS to the monitoring server, not the client.
#{% from "sensu/lib.sls" import sensu_check_procs with context %}
#{{ sensu_check_procs('mongod', pattern='mongod.*conf', critical_over=1, subscribers=['mongodb']) }}
