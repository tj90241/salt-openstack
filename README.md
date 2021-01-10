# salt-openstack

A SaltStack repository for configuring an opinionated OpenStack cluster.

## Planning and Base OS Install

An OpenStack cloud is a complex piece of infrastructure, and the additional
components which form a full `salt-openstack` cluster by no means make this
any less complex.  There's no canonical way to deploy a `salt-openstack`
cluster: you may have as few or many infrastructure roles as you like (e.g.,
a host for every role, or a condensed, low-footprint install where one or a
few infrastructure hosts serve many roles).

As a starting point, we recommend installing a development cluster where all
hosts are provisioned on the same subnet, in the same DNS domain, and where
each host serves a dedicated, specific role.  Although this may not be an
effective use of resources, or result in an environment in which it is easy to
to author effective security policies (as all hosts live in the same subnet),
you will be able to hit the ground running and avoid complex deployment issues
until you are more familiar with the `salt-openstack` cluster topology.

To begin, install [Debian GNU/Linux](https://www.debian.org/) as you normally
would on a set of hosts to be used with `salt-openstack`.  Below are the roles
of a `salt-openstack` cluster and suggested hostnames to use as a starting
point:

 * PyPI server: `devpi`
 * Salt Master: `salt`

## Preparing Local VMs (Homelab)

Use whatever tools you feel comfortable with if you are planning to host
your `salt-openstack` cloud on a virtualized environment on one or more
physical servers.  If you wish, a local tool built around `libvirt` is
included under the `scripts` directory.  Prerequisites for this solution
are the following:

  * `libvirt-daemon-system`
  * `openvswitch-switch`
  * `python3-libvirt`
  * `qemu-kvm`
  * `sgabios`

To cut down on some extra fat, you can pass `--no-install-recommends` when
installing these packages via `apt` to shed some unnecessary dependencies.

Next, set aside memory for your VMs by configuring hugepages in your kernel
(add `nr_hugepages=X` to the kernel command line, or
`echo X > /proc/sys/vm/nr_hugepages` to apply a temporary setting).  By
default, on x86(\_64), 1 hugepage = 2MB of RAM.  Then, configure the
`vm.hugetlb_shm_group` so that it has the gid of `kvm` (check what that is
with `cut -d: -f3 < <(getent group kvm)`).

Next, define some Open-vSwitch bridges in your networking configuration and
tie them to physical interfaces.  Here is an example `/etc/network/interfaces`
configuration whcih takes a physical interface, `enp3s0`, and ties VLAN 102
of that interface to a `br-util` bridge, while also adding a interface on that
bridge to the hypervisor (`vif-os-util`):

```
# The secondary network interface
allow-hotplug enp3s0
iface enp3s0 inet manual
        mtu 9000

auto enp3s0.102

# The utility network interface
allow-ovs br-util
iface br-util inet manual
        ovs_type OVSBridge
        ovs_ports enp3s0.102 vif-os-util
        mtu 9000

allow-br-util enp3s0.102
iface enp3s0.102 inet manual
        ovs_bridge br-util
        ovs_type OVSPort
        ovs_options tag=102

allow-br-util vif-os-util
iface vif-os-util inet static
        ovs_bridge br-util
        ovs_type OVSIntPort
        ovs_options vlan_mode=access tag=102

        address 10.10.2.1
        netmask 255.255.255.0
        network 10.10.2.0
        mtu 9000
```

and run `systemctl restart networking` to reflect those changes.

Next, define a storage pool in libvirt and mark it as autostart.  Setting up
a local storage pool and configuring it to autostart can be done as follows:

```
sudo virsh pool-define-as default dir - - - - /var/lib/libvirt/images/
sudo virsh pool-start default
sudo virsh pool-autostart default
```

Finally, boot VMs as needed.  They will PXE attempt to PXE to an installation
image.  The following example boots a VM named `salt` with the following
properties:

  * 1vCPU
  * 512MB RAM
  * 4GB root drive (sourced from the `default` storage pool)
  * a port with MAC `52:54:00:48:42:35`
  * ... attached to VLAN 102 on the `br-util` bridge

```
sudo ./virty create -c 1 -r 512 -s 4 -p default \
        -v 102 -m 52:54:00:48:42:35 br-util salt
```

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

## Setting up Dynamic DNS (optional)

A plugin for Hover (a domain registrar) is provided if you wish to make use
of dynamic DNS.  This will enable your cloud to be referenced externally on the
internet.  In order to do so, you must have a Hover account that has the A/AAAA
records you wish to maintain initially provisioned via Hover's web interface;
they will not be automatically created as needed.

To create a record, simply login to the Hover web interface, navigate to the
DNS tab, and create DNS records with any initial value, as shown below:

![Hover A record creation](/images/hover_create_a_record.png)

Once complete, create a pillar record for your WAN-facing host under the `hover`
pillar directory.  The name of the pillar file should be the name of the WAN-
facing host/minion (e.g., `/srv/pillar/hover/myhost.sls`).  In the pillar
file, use the template below to provide the domain(s) you wish to update, along
with the credentials for the domain.  You may then specify A/AAAA records to
maintain along with the interface on the minion which contains the publicly
routable address that should be used to populate the A/AAAA records.
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

To initially sync your A/AAAA records and setup a periodic job which maintains
them, simply run `salt -G roles:salt-master state.apply hover` on your Salt
Master host.  This will immediately provision the DNS records, and create a
scheduled Salt task that pushes your router's IP address(es) every 1 minute
past the hour.

## Setting up SSL Certificates and Keys (optional, recommended)

SSL certificates and keys are distributed to cloud infrastructure members via
the Salt Master by way of pillar data (which are AES-encrypted channels).  SSL
certificates and keys are expected to be found on the Salt Masters at
`/etc/salt/file_tree_pillar/hosts/<minion_name>/<pemfile>`, where `<pemfile>`
is all of:

  * `cert.pem`: The certificate for your domain (containing your public key)
  * `chain.pem`: The intermediate certificate (from your CA)
  * `privkey.pem`: The private key for your domain

These files and derivatives of the same will be rendered locally on cloud
infrastructure members when the associated minions run highstates (or whenever
the `ssl` state is applied on the minions).

To faciliate creation and renewal of SSL artifacts, this project can optionally
integrate with Let's Encrypt and Hover (a domain registrar) to automatically
renew certificates, even when one does not have a publicly-routable IP address.
This is done via DNS-based Let's Encrypt challenges.

In order to leverage this automated functionality, create a pillar record for
your Salt Master under the `certbot` pillar directory.  The name of the pillar
file should be the name of the Salt Master's Minion (by default, `salt`), e.g.:
`/srv/pillar/certbot/salt.sls`.  The key for each dictionary under `certs` is
the minion/host for which a SSL certificate should be generated and deployed.
A template for the file is as follows:
```
certbot:
  certs:
    salt:
      challenge: hover-dns
      email: someperson@somedomain.com
      hover_domain: example.com
      domains:
        - salt.example.com
        - salt-api.example.com
        - san.example.com

    infrahost1:
      challenge: hover-dns
      email: someperson@somedomain.com
      hover_domain: example.com
      domains:
        - infrahost1.example.com

hover:
  example.com:
    username: hoveruser
    password: hoverpassword
```

Note that your Salt Master's Minion must also have credentials for Hover in
order to push DNS TXT records for the challenge, so you must also minimally
also include your Hover credentials in the `certbot` pillar (as shown above)
for appropriate domains.

Lastly, for each domain (FQDN or SAN) for which you wish to provision SSL
certificates for, you must initially provision DNS TXT records in Hover. These
TXT records will be used by Let's Encrypt as part of the challenges (to verify
that you actually own the domain for which you are registering certificates
for).

The TXT records should have a hostname of `_acme-challenge.<yourhost>`, where
`<yourhost>` is the FQDN or SAN you wish to use, less the Hover domain name.
As an example, when creating an SSL certificate for `myhost.example.com`, you
would want to create a TXT record for `_acme-challenge.myhost`, as shown below:

![Hover TXT record creation](/images/hover_create_txt_record.png)

Once TXT records are created, simply run the following on your Salt Master:
`salt -G roles:salt-master state.apply certbot.renew; salt \* state.apply ssl`.
This will renew certificates and push them out to cloud infrastructure members
as necessary.  It will also schedule a task which checks if SSL certificates
need to be renewed twice daily.  Once/when renewed, certificates will be
deployed to cloud infrastructure members on their next highstate run.
