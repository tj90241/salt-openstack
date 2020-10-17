# salt-openstack

A SaltStack repository for configuring an opinionated OpenStack cluster.

## Bootstrapping the Salt Master

Install Debian GNU/Linux 10 ("buster") on a host which is destined to become
the Salt Master for your cloud.  While you may conjoin roles of hosts in your
cluster, it is recommended to use a separate host for this purpose, even if it
is virtual.  The Salt Master must be able to communicate with every host which
participates in your cloud infrastructure, so be sure to provision it in a
network that is suitable and can be secured properly for this purpose.

Once complete, upload `scripts/baseline-salt-master` to the host and execute
the script as `root`. The script will setup the Salt infrastructure and clone
this repository into `/srv`.

## Setting up Dynamic DNS

A plugin for Hover (a domain registrar) is provided if you wish to make use
of dynamic DNS.  This will enable your cloud to be referenced externally on the
internet.  In order to do so, you must have a Hover account that has the A/AAAA
records you wish to maintain initially provisioned via Hover's web interface;
they will not be automatically created as needed.

Once complete, create a pillar record for your WAN-facing host under the `hover`
pillar directory.  The name of the pillar file should be the name of the WAN-
facing minion (e.g., `/srv/pillar/hover/some_minion.sls`).  In the pillar file,
use the template below to provide the domain(s) you wish to update, along with
the credentials for the domain.  You may then specify A/AAAA records to maintain
along with the interface on the minion which contains the publicly routable
address that should be used to populate the A/AAAA records.
```
hover:
  example.com:
    username: hoveruser
    password: hoverpassword

    a_records:
      interface: eth0
      hosts:
        - '@'
        - '*'

    aaaa_records:
      interface: eth0
      hosts:
        - '@'
        - '*'
```
