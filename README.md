# pe_satellite

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with pe_satellite](#setup)
    * [What [modulename] affects](#what-pe_satellite-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with pe_satellite](#beginning-with-pe_satellite)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

The pe_satellite module configures Puppet's report processor and facts indirector to allow you to send Puppet reports and facts to your Red Hat Satellite server.

## Setup

### Requirements

This module requires Puppet Enterprise 3.8.1 or later.

### Set up the pe_satellite module

1. [Classify Puppet Enterprise masters](#classify-puppet-enterprise-masters)
2. [Allow Puppet Enterprise Master to Send Data to Satellite](#Allow-Puppet-Enterprise–Master-to-Send-Data-to-Satellite)
3. [Satellite Server Identity Verification](#Satellite-Server-Identify-Verification)

1. Classify Puppet Enterprise Masters

  Add the `pe_satellite` class to the PE Master node group in the Puppet Enterprise Console.

**TODO**: Add classifier instructions?

2. Set PE Master Facts Terminus

In the 'PE Master' nodegroup in the PE Console, add the *facts_terminus*
parameter to the *puppet_enterprise* class with a String value of *satellite*.
When puppet runs on the PE masters, it will be set to forward the facts to
Satellite.

# Allow Puppet Enterprise Master to Send Data to Satellite

By default, the Satellite server only allows Satellite capsules and Smart
Proxies to send facts and reports to the Satellite server.  Each Puppet
Enterprise Master needs to be allowed to send facts and reports as well.  To do
so, in the Satellite UI go to *Administer -> Settings -> Auth* and add the
hostname of each Puppet Enterprise Master to the *trusted_puppetmaster_hosts*
parameter value's array.

# Satellite Server Identify Verification

In order to use SSL verification, which prevents man in the middle attacks, the
Certificate Authority (CA) certificate that signed the Satellite server's SSL
certificate needs to be available on the Puppet Enterprise Master.

Note, if you do not wish to verify the identity of the Satellite server, the
*verify_satellite_certificate* parameter for the *pe_satellite* class can be
set to false.

## Self Signed Certificates

If the Satellite installation uses a self signed certificates (you'll know if
your browser is unable to verify the server's identity when you connect to the
Satellite UI), the CA certificate is located on the Satellite CA server.  Copy
the file */etc/pki/katello/certs/katello-default-ca.crt* from the Satellite CA
server to */etc/puppetlabs/puppet/ssl/ca/katello-default-ca.crt* on each Puppet
Enterprise Master.   Note if you place the certificate in a different location
or give it a different name, you'll need to set the *ssl_ca* parameter for the
pe_satellite class to the file path of the CA certificate

## Remote CA Signed

If the Satellite SSL certificate is signed by a remote CA, the remote's CA
certificate will need to be in
*/etc/puppetlabs/puppet/ssl/ca/ca-certificate.crt*. You will need to set the
*ssl_ca* parameter for the *pe_satellite* class to the file path of the CA
certificate.

# Puppet Enterprise Master Identity Verification

By default, Satellite is configured to verify the SSL identity of the Puppet
Enterprise masters connecting to it. Without the Puppet Enteprise Satellite
report processor and facts indirector using a certificate signed with the
Satellite Server's CA certificate, the verification will fail. There are two
options available. Satellite can either be configured to not verify the Puppet
Masters identity, or a custom certificate for each Puppet Master can be
generated and signed with the CA certificate signed by the Satellite server's
CA certificate.

## Disabling PE Master verification

In the Satellite UI, go to *Administer -> Settings -> Auth* and set the
*restrict_registered_puppetmasters* parameter to false.

## Generating a certificate for each PE master

???

## Basic Usage examples

~~~puppet
class {'pe_satellite':
	satellite_url => "https://satellite.example.com",
    verify_satellite_certificate => false,
}
~~~


## Reference

This module provides one class, *pe_satellite* that configures the report
processor and facts indirector to know how to communicate with Satellite.

### Class: pe_satellite

This module provides one class, *pe_satellite* that configures the report
processor and facts indirector to know how to communicate with Satellite.

#### Parameters

All parameters are required unless otherwise specified.

* `satellite_url` - *Required.* The full URL to the satellite server in format https://url.to.satellite.

* `ssl_ca` - Optional. The file path to the CA certificate used to verify the satellite server identitity. If not provided, the local Puppet Enterprise master's CA is used. Default: `/etc/puppetlabs/puppet/ssl/ca/katello-default-ca.crt`.

* `ssl_cert` - The file path to the certificate signed by the Satellite CA. It's used for Satellite to verify the identity of the Puppet Enterprise master. Default: `/etc/puppetlabs/puppet/ssl/certs/$(satellite_fqdn).pem`.

* `ssl_key` - The file path to the key for the Puppet Enterprise master generated by Satellite. Default: `/etc/puppetlabs/puppet/ssl/certs/$(pe_master_fqdn).pem`

* `verify_satellite_certificate` - When set to 'true', allows the Satellite server to present an unsigned, unrecognised, or invalid ssl certificate. Defaults to 'true'.

## Supported

Supports Puppet Enterprise 2015.2.x running on Red Hat 7, CentOS 7, Oracle Linux 7 and Scientific Linux 7.
Requires Red Hat Satellite 6
