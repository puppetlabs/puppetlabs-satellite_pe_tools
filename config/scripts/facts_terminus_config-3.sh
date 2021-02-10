#!/bin/bash

declare -x PE_CERT=$(/opt/puppet/bin/puppet agent --configprint hostcert)
declare -x PE_KEY=$(/opt/puppet/bin/puppet agent --configprint hostprivkey)
declare -x PE_CA=$(/opt/puppet/bin/puppet agent --configprint localcacert)
declare -x PE_CERTNAME=$(/opt/puppet/bin/puppet agent --configprint certname)

declare -x NC_CURL_OPT="-s --cacert $PE_CA --cert $PE_CERT --key $PE_KEY --insecure"

find_guid()
{
  echo $(curl $NC_CURL_OPT --insecure https://localhost:4433/classifier-api/v1/groups| python -m json.tool |grep -C 2 "$1" | grep "id" | cut -d: -f2 | sed 's/[\", ]//g')
}

read -r -d '' PE_SERVER_POST << SERVER_JSON
{
  "classes": {
    "pe_repo": { },
    "pe_repo::platform::el_6_x86_64": {},
    "pe_repo::platform::el_7_x86_64": {},
    "pe_repo::platform::ubuntu_1204_amd64": {},
    "pe_repo::platform::ubuntu_1404_amd64": {},
    "puppet_enterprise::profile::master": { "facts_terminus": "satellite" }
  },
  "environment": "production",
  "environment_trumps": false,
  "id": "$(find_guid 'PE Master')",
  "name": "PE Master",
  "parent": "$(find_guid 'PE Infrastructure')",
  "rule": [
    "or",
    [ "=", "name", "$PE_CERTNAME" ]
  ],
  "variables": {}
}
SERVER_JSON

curl -X POST -H 'Content-Type: application/json' -d "$PE_SERVER_POST" $NC_CURL_OPT --insecure https://localhost:4433/classifier-api/v1/groups/$(find_guid 'PE Master')

