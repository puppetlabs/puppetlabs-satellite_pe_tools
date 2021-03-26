#!/bin/sh

if ! [ -d /opt/satellite ]; then
  mkdir -p /mnt/iso
  if [[ -z ${CLOUD_CI} ]]; then
    gsutil cp -r gs://artifactory-modules/satellite-6.2.7-rhel-7-x86_64-dvd.iso /tmp/ 
  else
    curl https://artifactory.delivery.puppetlabs.net/artifactory/list/generic/module_ci_resources/carl/satellite-6.2.7-rhel-7-x86_64-dvd.iso > /tmp/satellite-6.2.7-rhel-7-x86_64-dvd.iso
  fi
  mount /tmp/satellite-6.2.7-rhel-7-x86_64-dvd.iso -o loop /mnt/iso
  
  cd /mnt/iso
  /mnt/iso/install_packages

  satellite-installer --scenario satellite  --foreman-admin-password "puppetlabs"

  puppet agent -t
fi
