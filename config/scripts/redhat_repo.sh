#!/bin/sh 

cat << EOF > /etc/yum.repos.d/media.repo
[InstallMedia]
name=RHEL-7.2 Server.x86_64
mediaid=1399449226.171922
metadata_expire=-1
gpgcheck=0
cost=500
baseurl=http://osmirror.delivery.puppetlabs.net/rhel7latestserver-x86_64/RPMS.all
EOF

yum makecache
