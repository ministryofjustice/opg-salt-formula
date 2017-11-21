users-formula
==============

for each user defined in the ``users`` pillar dict:

 - create the user account
 - create entires in .ssh/authorized_keys2

*or*:

 - remove the account if ``absent`` is in the pillar structure


example::

    users:
      username:
        # Old format with just a single ssh public key
        key: your_key
        comment: your key_name, comment
        enc: ssh-rsa
      jobloggs:
        # New format with multiple keys
        public_keys:
          - key: AAAAB3n....=
            enc: ssh-rsa
            comment: oncall-laptop-1.local
          - key: AAAAB3n....=
            enc: ssh-rsa
            comment: dekstop2.jo.local
      rogue:
        absent: True
