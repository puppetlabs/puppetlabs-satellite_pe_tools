#!/bin/sh

if ! [ -d /opt/satellite ]; then
  mkdir -p /mnt/iso
  /usr/bin/gsutil cp gs://artifactory-modules/satellite-6.13.1-rhel-8-x86_64.dvd.iso /tmp/satellite-6.13.1-rhel-8-x86_64.dvd.iso
  mount /tmp/satellite-6.13.1-rhel-8-x86_64.dvd.iso -o loop /mnt/iso
  
  cd /mnt/iso
  /mnt/iso/install_packages

  puppet agent -t

  setenforce 0
  satellite-installer --scenario satellite --enable-puppet --enable-foreman-cli-puppet --foreman-initial-admin-password "puppetlabs" --tuning development -l DEBUG
  setenforce 1
fi
