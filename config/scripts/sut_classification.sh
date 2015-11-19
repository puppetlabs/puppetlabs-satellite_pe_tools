#!/bin/bash

if [[ $PE_DIR =~ .*3\.8.* ]]; then
  PUPPET_BINARY_PATH='/opt/puppet/bin/puppet'
else
  PUPPET_BINARY_PATH='/opt/puppetlabs/bin/puppet'
fi

declare -x PE_CERT=$($PUPPET_BINARY_PATH agent --configprint hostcert)
declare -x PE_KEY=$($PUPPET_BINARY_PATH agent --configprint hostprivkey)
declare -x PE_CA=$($PUPPET_BINARY_PATH agent --configprint localcacert)
declare -x PE_CERTNAME=$($PUPPET_BINARY_PATH agent --configprint certname)

declare -x NC_CURL_OPT="-s --cacert $PE_CA --cert $PE_CERT --key $PE_KEY --insecure"

find_guid()
{
  echo $(curl $NC_CURL_OPT --insecure https://localhost:4433/classifier-api/v1/groups| python -m json.tool |grep -C 2 "$1" | grep "id" | cut -d: -f2 | sed 's/[\", ]//g')
}

read -r -d '' PE_MASTER_POST << MASTER_JSON
{
  "classes": {
    "satellite_pe_tools::acceptance": {}
  }
  "environment": "production",
  "environment_trumps": false,
  "name": "Satellite SUT",
  "parent": "$(find_guid 'All Nodes')",
  "rule": ['and', ['=', ['fact', 'role'], 'satellite_sut']],
  "variables": {}
}
MASTER_JSON

curl -X POST -H 'Content-Type: application/json' -d "$PE_MASTER_POST" $NC_CURL_OPT --insecure https://localhost:4433/classifier-api/v1/groups

