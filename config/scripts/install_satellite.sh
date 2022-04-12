#!/bin/sh

if ! [ -d /opt/satellite ]; then
  mkdir -p /mnt/iso
  # Replace below line with command in acceptance_local to copy files over
  # curl https://artifactory.delivery.puppetlabs.net/artifactory/list/generic/module_ci_resources/carl/satellite-6.2.7-rhel-7-x86_64-dvd.iso > /tmp/satellite-6.2.7-rhel-7-x86_64-dvd.iso
  mount /tmp/satellite-6.2.7-rhel-7-x86_64-dvd.iso -o loop /mnt/iso
  
  cd /mnt/iso
  /mnt/iso/install_packages

  satellite-installer --scenario satellite  --foreman-admin-password "puppetlabs"

  puppet agent -t
fi
