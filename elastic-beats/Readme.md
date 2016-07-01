Elastic search beats
--------------------

This formula will configure the elastic search beats as defined in the pillar data.

All minions will run the state if the pillar data is available.

The formula assumes the beats are in place as they are part of the AMI image.

Common config
-------------

**es_server** name/IP of elastic search server

See [pillar.example](pillar.example) for pillar data
