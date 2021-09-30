# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/bullseye64"

  # Share the salt-openstack repository with all hosts.
  # In a production environment, scripts can be loaded via TFTP/PXE.
  config.vm.synced_folder ".", "/salt-openstack",
    :type => "nfs",
    :nfs_version => 4,
    :nfs_udp => false

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 1
    vb.memory = "1024"
  end

  config.vm.provider "libvirt" do |v|
    v.driver = "kvm"
    v.machine_type = "q35"
    v.cpu_model = "host-passthrough"
    v.nested = false
    v.memorybacking :hugepages
    v.cpus = 1
    v.memory = "1024"
    v.graphics_type = "none"
    v.disk_bus = "scsi"
    v.disk_device = "sda"
  end

  # -----------------------------------
  #  salt-openstack-master
  # -----------------------------------
  config.vm.define "salt-openstack-master" do |salt|
    salt.vm.hostname = 'salt'

    # Invoke the baseline-salt-master script ont he salt-openstack master.
    salt.vm.provision "shell", inline: <<-SHELL
      cp -ar /salt-openstack{,.local}/
      SALT_OPENSTACK_REPO=/salt-openstack.local /salt-openstack/scripts/baseline-salt-master

      # The network "blips" during the build, so we made to make a local copy.
      # Copy credentials, etc. back into the share and nuke the copy.
      apt-get install -y rsync
      rsync -av /salt-openstack{.local,}/pillar/
      apt-get purge -y rsync

      rm -f /srv/{pillar,salt,scripts}
      ln -sfv /salt-openstack/pillar /srv/pillar
      ln -sfv /salt-openstack/salt /srv/salt
      ln -sfv /salt-openstack/scripts /srv/scripts
      rm -rf /salt-openstack.local
    SHELL

    # Assign extra compute resources to the salt-openstack master.
    salt.vm.provider "virtualbox" do |vb|
      vb.name = "salt-openstack-master"
      vb.cpus = 2
    end

    salt.vm.provider "libvirt" do |libvirt|
      libvirt.cpus = 2
    end
  end

  # -----------------------------------
  #  salt-openstack-leader*
  # -----------------------------------
  (1..3).each do |leader_id|
    config.vm.define "salt-openstack-leader#{leader_id}" do |leader|
      leader.vm.hostname = "leader#{leader_id}"

      leader.vm.provider "virtualbox" do |vb|
        vb.name = "salt-openstack-leader#{leader_id}"
      end

      leader.vm.provision "shell", inline: <<-SHELL
        /salt-openstack/scripts/baseline-salt-minion
      SHELL
    end
  end
end
