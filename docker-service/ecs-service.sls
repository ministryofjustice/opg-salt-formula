#anatomy of an ecs service.
# elb is required for managing location of container in cluster, although consul can provide provides the same service via DNS/consul agent
# elb is required for load balanced access and external access
# task definition -> json format from template
# service definition -> aws resource
# persistent data dirs -> create dirs and deliver config from templates.

#include:
#  - aws_rds
#  - aws_elb
#  - aws_service
#  - aws_task
#  - aws_dns

{% for service_name in pillar['services'] %}
{%     if pillar['services'][service_name]['type'] | default('compose') == 'ecs' %}
{%         %}
{%     endif %}
{% endfor %}
