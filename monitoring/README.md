salt-formula::monitoring
=====================

Based on the formulas found originally in opg-monitoring formula, this is designed to add
monitoring to the stack.

The main difference between this and the original formula is that now the stack comes up using
 the services section of the docker compose formula. All client configuration is done in your
 pillars' base and the server configuration is done on the role

![opg-docker-monitoring overview](https://cloud.githubusercontent.com/assets/13198078/8695568/a18a5fc6-2add-11e5-8377-7fe6b613f870.jpg "Docker monitoring overview")

# Links

http://grafana.your_domain/

Grafana js based dashboards expect to reach graphite directly through:

http://graphite.your_domain/

for debugging you can use: $(boot2docker ip).xip.io:8080.

http://sensu.your_domain/

for debugging you can use: $(boot2docker ip).xip.io:8080.

# Containers

## Monitoring-proxy

Container that acts as a single monitoring endpoint for your application
while shipping data it allows you to:

- tag logs
- prefix collectd metrics (ships them to graphite)
- prefix and aggregate statsd metrics (ships them to graphite)

Ports:

- 2514 tcp/udp (syslog input)
- 6379 tcp (redis input, scans logstash key)
- 8125 udp (statsd input)
- 25826 (collectd listener)

Example options:

- MONITORING_REDIS_HOST: redis:6379/0
- MONITORING_GRAPHITE: graphite
- MONITORING_NAMESPACE: myapp.prod

TODO: Replace logstash with a lightweight implementation (small golang process).

## Logstash

Listens for logs (pulls logs from redis queue) and ships them to elasticsearch:9200.

Further log parsing will be added here at the moment we are also generating statsd metrics on incoming logs.

There are three environment variables which can be used to point logstash at elasticsearch and use SSL (or plain text) for transmission:

- OPG_LOGSTASH_ELASTICSEARCH_HOSTPORT
- OPG_LOGSTASH_ELASTICSEARCH_SSL_ENABLED
- OPG_LOGSTASH_ELASTICSEARCH_SSL_CERTIFICATE_VERIFICATION

`OPG_LOGSTASH_ELASTICSEARCH_HOSTPORT` specifies the `host:port` combination to define the elasticsearch host/port. Default is `elasticsearch:9200`. This has been tested pointing to an AWS Elasticsearch cluster (using the AWS ES service).

`OPG_LOGSTASH_ELASTICSEARCH_SSL_ENABLED` is a boolean value specifying if transport to elasticsearch should be over SSL. Default is `false`.

`OPG_LOGSTASH_ELASTICSEARCH_SSL_CERTIFICATE_VERIFICATION` is a boolean value specifying if the server certificate should be validated or not. Default is `false` (as SSL default is `false` to preserve backwards compatibility with existing setup where transport is plain text).

## Graphite-Statsd

A pre-configured graphite.

## Grafana

A pre-configured grafana with autogenerating dashboards:

https://grafana.(domainname)/dashboard/script/overview.js?env=(metrics_prefix)


## Collectd

Collectd configured to feed metrics to a carbon collector on port 2003. For more information on collectd see https://collectd.org/.

This implementation of collectd comes with a few basic checks, as well as a custom btrfs check from https://github.com/soellman/docker-collectd


## App

Demo web app container (to demonstrate use of monitoring proxy).

## Sensu

The defautl log_level is 'warn'.  To change this use the following environment variable:
-  SENSU_DEFAULT_LOG_LEVEL


## Sensu-Client

#### Base checks

Base checks are designed to go into the `base.sls` pillar so applied to everything.

Environment variables (mandatory for each check):

- SENSU_CLIENT_CHECKS_BASE_checkname_NAME
- SENSU_CLIENT_CHECKS_BASE_checkname_COMMAND

where `checkname` is the name of the check.

Environment variables (optional for each check):

- SENSU_CLIENT_CHECKS_BASE_checkname_SUBSCRIBERS (default "all")
- SENSU_CLIENT_CHECKS_BASE_checkname_INTERVAL (default 60)

where `checkname` is the name of the check.

#### Subduing a check

In addition to the ability to fully disable the handling of certain checks, Sensu supports ‘subduing’ checks so that they are not handled during certain hours of the day. This is done by configuring the "begin" and "end" times for the check’s "subdue" attribute.

- SENSU_CLIENT_CHECKS_BASE_checkname_SUBDUEBEGIN
- SENSU_CLIENT_CHECKS_BASE_checkname_SUBDUEEND

e.g.

- SENSU_CLIENT_CHECKS_BASE_LOADSHORTTERM_SUBDUEBEGIN=5AM UTC
- SENSU_CLIENT_CHECKS_BASE_LOADSHORTTERM_SUBDUEEND=7PM UTC

NOTE: BOTH must be supplied (BEGIN and END) or neither.

#### Default subdue

If you want to set a global subdue window for all checks, you can use the following variables:

- SENSU_CLIENT_CHECKS_BASE_SUBDUEBEGIN
- SENSU_CLIENT_CHECKS_BASE_SUBDUEEND

NOTE: BOTH must be supplied (BEGIN and END) or neither.

If none of the subdue variables above are set, the default will be that NO SUBDUE window is defined.

An individual check based subdue window will override a global subdue window which will override the default.

For  more information on Sensu checks please refer to https://sensuapp.org/docs/latest/checks

#### Role checks

Role based checks are designed to go into a `role` pillar so used only on a set of servers in a particular role.

The variables for role checks are the same as those described above with the `BASE` in the variable name replaced with `ROLE` e.g.

- SENSU_CLIENT_CHECKS_ROLE_BTRFSPCTUSED_NAME
- SENSU_CLIENT_CHECKS_ROLE_BTRFSPCTUSED_COMMAND

#### Plugins

The `opg-check-elasticrecent.sh` plugin will check whether there are particular Elasticsearch index entries for a specified index within a recent time period. The `ELASTIC_INDEX` variable should be set to the index to check. The default is `logstash-$(date '+%Y.%m.%d')`. The time period can be specified with the `SENSU_CLIENT_ELASTIC_RECENT` variable (see below). The default for this variable is `5m` and should follow the standard format for Elasticsearch Query DSL filters.

The `opg-check-functions.sh` is designed to contain reusable functions that can be called by other plugins. e.g. the `curl_and_return` function can be used to return the output from a curl command back to the caller. Any functions that can be reused should be added to this plugin and should be defined with the `function` statement so that they are exported correctly for child processes to call on.

The `opg-check-wrapper.sh` is designed to be used to invoke both community and in-house developed plugins. It sets up a number of variables that can be used by in-house developed plugins based on environment variables passed into the docker container at startup by an env file:

- SENSU_CLIENT_CURL_TIMEOUT
- SENSU_CLIENT_ELASTIC_PORT
- SENSU_CLIENT_ELASTIC_RECENT

The default values plus an explanation of each variable can be found in the comments within the wrapper plugin. Any additional variables used by newly developed plugins should be setup with defaults in the same way. Other variables passed in via docker environment files can be passed straight to community plugins.

The wrapper also sets up a variable `DEFAULT_HOST` which is the IP address of the default gateway (which inside docker is the method for gaining access to ports exposed by other containers to the host).

To invoke a plugin via the wrapper simply set `OPG_CHECK` to whatever should be run to initiate the check and the wrapper will execute and return the exit code from it back to Sensu. Therefore in-house written checks should follow the standard exit codes for Sensu as desribed at https://sensuapp.org/docs/latest/checks

The following are examples of pillar defining checks that use the wrapper (both in-house developed as well as community plugin checks):

`SENSU_CLIENT_CHECKS_ROLE_ESRECENT_NAME: esrecent`
`SENSU_CLIENT_CHECKS_ROLE_ESRECENT_COMMAND: "export ELASTIC_INDEX='.marvel-$(date +%Y.%m.%d)' ; export SENSU_CLIENT_ELASTIC_RECENT=20m ; export OPG_CHECK='/etc/sensu/plugins/opg-check-elasticrecent.sh' ; /etc/sensu/plugins/opg-check-wrapper.sh"`

`SENSU_CLIENT_CHECKS_ROLE_REDIS_NAME: redis`
`SENSU_CLIENT_CHECKS_ROLE_REDIS_COMMAND: "export OPG_CHECK='/opt/sensu/embedded/bin/check-redis-ping.rb --host $DEFAULT_HOST --port $SENSU_CLIENT_REDIS_PORT' ; /etc/sensu/plugins/opg-check-wrapper.sh"`

`SENSU_CLIENT_CHECKS_ROLE_KIBANA_NAME: kibana`
`SENSU_CLIENT_CHECKS_ROLE_KIBANA_COMMAND: "export OPG_CHECK='/opt/sensu/embedded/bin/check-http.rb --url http://$DEFAULT_HOST:$SENSU_CLIENT_KIBANA_PORT' ; /etc/sensu/plugins/opg-check-wrapper.sh"`

`SENSU_CLIENT_CHECKS_ROLE_ELASTIC_NAME: elastic`
`SENSU_CLIENT_CHECKS_ROLE_ELASTIC_COMMAND: "export OPG_CHECK='/opt/sensu/embedded/bin/check-http.rb --url http://$DEFAULT_HOST:$SENSU_CLIENT_ELASTIC_PORT' ; /etc/sensu/plugins/opg-check-wrapper.sh"`

`SENSU_CLIENT_CHECKS_ROLE_ESHEAP_NAME: esheap`
`SENSU_CLIENT_CHECKS_ROLE_ESHEAP_COMMAND: "export OPG_CHECK='/opt/sensu/embedded/bin/check-es-heap.rb --host $DEFAULT_HOST --port $SENSU_CLIENT_ELASTIC_PORT -P -w 80 -c 90' ; /etc/sensu/plugins/opg-check-wrapper.sh"`

`SENSU_CLIENT_CHECKS_ROLE_ESNODE_NAME: esnode`
`SENSU_CLIENT_CHECKS_ROLE_ESNODE_COMMAND: "export OPG_CHECK='/opt/sensu/embedded/bin/check-es-node-status.rb --host $DEFAULT_HOST --port $SENSU_CLIENT_ELASTIC_PORT' ; /etc/sensu/plugins/opg-check-wrapper.sh"`

## Sensu-Server

Environment variables with defaults:

- SENSU_REDIS_HOST
- SENSU_REDIS_PORT
- SENSU_RABBITMQ_HOST
- SENSU_RABBITMQ_PORT
- SENSU_RABBITMQ_VHOST
- SENSU_RABBITMQ_USER
- SENSU_RABBITMQ_PASSWORD
- SENSU_API_PORT
- SENSU_API_HOST

#### Handlers

Environment variables for the PagerDuty handler:

- SENSU_HANDLER_PAGERDUTY_APIKEY

Environment variables for the Slack handler:

- SENSU_HANDLER_SLACK_WEBHOOKURL (Slack webhook configured to send events via)
- SENSU_HANDLER_SLACK_CHANNEL (Slack channel to send events to)
- SENSU_HANDLER_SLACK_BOTNAME (Name given to event sender in Slack)

Environment variables for the AWS SNS handler:

- SENSU_HANDLER_SNS_TOPICARN (The AWS SNS Topic ARN to send events to)
- SENSU_HANDLER_SNS_REGION (The AWS region for the Topic)

#### Handler Notes

- If environment variables for the any of the handlers above do not exist then the handler is not configured at all.
- When they exist, all variables for a handler should be defined and when they do the handler is also configured as a default handler within Sensu.
- It is then up to how you configure the underlying handler as to what sort of events it handles e.g. critical events only.

## Uchiwa

OPG Uchiwa was originally designed to run alongside a local Sensu API service on the same host (in the same docker-compose) called sensuapi. This was achieved by setting a number of environment variables for docker that defined the single end point in the `/etc/sensu/uchiwa.json` configuration file (see sample `env` file in this repository) and adding a `link` in the docker-compose file.

This method has been preserved for backwards compatibility so that existing environments can run unchanged with the version that supports multiple end points. If none are defined it reverts to the default config.

To configure multiple Sensu API end points (Data Centers) you need to define how many and then define each one using the following variables:

- UCHIWA_SENSU_MULTIPLE (number of data centres minus one - indexing starts from zero)


- UCHIWA_SENSU_DC_name_NAME
- UCHIWA_SENSU_DC_name_HOST
- UCHIWA_SENSU_DC_name_PORT
- UCHIWA_SENSU_DC_name_SSL
- UCHIWA_SENSU_DC_name_INSECURE
- UCHIWA_SENSU_DC_name_USER
- UCHIWA_SENSU_DC_name_PASS
- UCHIWA_SENSU_DC_name_TIMEOUT

where `name` is a unique name for each data center defined. The number defined should match `UCHIWA_SENSU_MULTIPLE` minus one (as the index of elements begins at zero`).

It is VERY IMPORTANT that `UCHIWA_SENSU_MULTIPLE` accurately reflects the actual number of Data Centers defined and that each is fully defined. Anything not matching is likely to result in Uchiwa failing to start (either through confd errors or invalid json rendered).

See the `env` file in this repository for examples of multiple data centers.

#Example configuration