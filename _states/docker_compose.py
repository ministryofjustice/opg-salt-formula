"""
a state that ensures that all containers run by docker-compose are up
it executes `docker-compose up -d --x-smart-recreate`
and parses the output

1) on all marked as Starting
returns state as updated

2) on all up-to-date
returns state as unmodified

3) on any failed to create
returns state as failed


pre-requisite: docker-compose >=1.3 rc1

i.e.:
my_project_up:
  docker_compose.up:
    - config: /etc/docker-compose/docker-compose-app.yml
    - project: my_project
    - cmd: /opt/bin/docker-compose-1.3


future:
docker-swarm integration
extra option to force pull images

"""

import logging

import salt.utils
from salt.exceptions import CommandExecutionError
from salt._compat import string_types


log = logging.getLogger(__name__)


def up(name, config, project=None, cmd="docker-compose", pull=True, env={}):
    ret = {
        'name': name,
        'changes': {},
        'result': True,
        'comment': ''
    }
    result, changes, comment = __salt__['docker_compose.up'](config, project=project, cmd=cmd, pull=pull, env=env)

    ret['result'] = result
    ret['changes'] = changes
    ret['comment'] = comment
    return ret
