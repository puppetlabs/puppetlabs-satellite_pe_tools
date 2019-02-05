#!/bin/sh

if ! [ -d /opt/satellite ]; then
  mkdir -p /mnt/iso
  curl http://10.234.0.63:8080/carl/satellite-6.2.7-rhel-7-x86_64-dvd.iso > /tmp/satellite-6.2.7-rhel-7-x86_64-dvd.iso
  mount /tmp/satellite-6.2.7-rhel-7-x86_64-dvd.iso -o loop /mnt/iso
  
  cd /mnt/iso
  /mnt/iso/install_packages

  satellite-installer --scenario satellite  --foreman-admin-password "puppetlabs"

  puppet agent -t
fi
