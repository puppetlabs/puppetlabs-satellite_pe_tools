#!/bin/sh

ip_ranges=$1
port_range=$2
default_allowed_ports="tcp:22,tcp:443,tcp:80,tcp:5985,tcp:5986,tcp:3389,tcp:5432,tcp:55433"

name=$(curl -H "Metadata-Flavor:Google" http://metadata/computeMetadata/v1/instance/name)
region=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/zone" | cut -d/ -f4)
gcloud config set compute/zone $region
firewall=$(gcloud compute instances describe $name --format='get(tags.items.filter(startswith("firewall-")))')

for f_name in ${firewall[@]}
do
  gcloud compute firewall-rules update $f_name --source-ranges=$ip_ranges --allow=$port_range,$default_allowed_ports
done
