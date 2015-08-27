bootstrap-formula
=================

Set of states that create basic skeleton for servers.
 - directories
 - groups
 - useful packages (don't assume that they are installed)
 - disable automatic service start after installation so that we can first configure them safely

usage::

    include:
      - bootstrap
      - bootstrap.motd
