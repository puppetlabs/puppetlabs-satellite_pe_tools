# pe_satellite

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with pe_satellite](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with pe_satellite](#beginning-with-pe_satellite)
3. [About Satellite Certificates](#about-satellite-certificates)
    * [Self-signed certificates](#self-signed-certificates)
    * [Certificates signed by remote CA](#certificates-signed-by-remote-CA)
4. [PE Master Identity Verification](#pe-master-identity-verification)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

The pe_satellite module configures Puppet's report processor and facts indirector to allow you to send Puppet reports and facts to your Red Hat Satellite server.

## Setup

### Setup requirements

This module requires Puppet Enterprise 3.8.1 or later.

### Beginning with pe_satellite

To set up pe_satellite to communicate with your Satellite servers, you need to:

1. [Classify Puppet Enterprise masters](#classify-puppet-enterprise-masters)
2. [Allow Puppet Enterprise master to send data to satellite](#allow-puppet-enterprise–master-to-send-data-to-satellite)
3. [Verify Satellite server identity](#verify-satellite-server-identity)

Continue reading for details about each of these steps:

1. Classify Puppet Enterprise masters

   Add the `pe_satellite` class to the PE Master node group in the Puppet Enterprise Console. For details on adding classes to node groups, see the [Puppet Enterprise documentation](#https://docs.puppetlabs.com/pe/latest/console_classes_groups.html#adding-classes-to-a-node-group).

2. Set PE Master facts terminus

  In the PE Master node group in the PE Console, add the `facts_terminus`
parameter to the `puppet_enterprise` class with a string value of 'satellite'.
This sets Puppet runs on PE masters to forward the facts to Satellite.

3. Allow Puppet Enterprise master to send data to Satellite

  By default, the Satellite server only allows Satellite capsules and Smart
Proxies to send facts and reports to the Satellite server. To allow each PE master to send facts and reports as well: 
    
    1. In Satellite, go to **Administer -> Settings -> Auth**
    2. Add the hostname of each PE master to the `trusted_puppetmaster_hosts`
parameter value's array.

4. Verify Satellite Server Identity

  To use SSL verification, which prevents man-in-the-middle attacks, the
Certificate Authority (CA) certificate that signed the Satellite server's SSL
certificate must be available on the Puppet Enterprise master.

  Note that if you do not wish to verify the identity of the Satellite server, you can set the
[`verify_satellite_certificate`](#verify_satellite_certificate) parameter for the `pe_satellite` class to false.

## About Satellite Certificates

### Self-signed certificates

If the Satellite installation uses a self-signed certificate, then the CA certificate is located on the Satellite CA server. (You'll know it's a self-signed certificate if
your browser is unable to verify the server's identity when you connect to the
Satellite UI.)

If this is the case, copy the file `/etc/pki/katello/certs/katello-default-ca.crt` from the Satellite CA server to `/etc/puppetlabs/puppet/ssl/ca/katello-default-ca.crt` on each PE master. Note that if you place the certificate in a different location
or give it a different name, you'll need to set the `ssl_ca` parameter for the
`pe_satellite` class to the file path of the CA certificate.

### Certificates signed by remote CA

If the Satellite SSL certificate is signed by a remote CA, the remote's CA
certificate needs to be in
`/etc/puppetlabs/puppet/ssl/ca/ca-certificate.crt`. Set the `ssl_ca` parameter for the `pe_satellite` class to the file path of the CA certificate.

## PE Master Identity Verification

By default, Satellite is configured to verify the SSL identity of the Puppet
Enterprise masters connecting to it. If the PE report processor and facts indirector are not using a certificate signed with the Satellite server's CA, the verification fails. 

You can either:

* Generate a custom certificate for each Puppet master, signed with the Satellite server's CA certificate, OR
* Configure satellite to *not* verify the Puppet master's identity.

### Generating a certificate for each PE master

**TODO: I don't think we need to explain how to do this in this README, but maybe a link to the info would be useful?**

### Disabling PE Master verification

In the Satellite UI, go to *Administer -> Settings -> Auth* and set the
*restrict_registered_puppetmasters* parameter to false.

## Usage

*TODO: What does this example do?**

~~~puppet
class {'pe_satellite':
	satellite_url => "https://satellite.example.com",
    verify_satellite_certificate => false,
}
~~~

## Reference

### Class: pe_satellite

This module provides one class, *pe_satellite* that configures the report
processor and facts indirector to know how to communicate with Satellite.

#### Parameters

All parameters are **required** unless otherwise specified.

* `satellite_url` - The full URL to the satellite server in format https://url.to.satellite.

* `ssl_ca` - **Optional**. The file path to the CA certificate used to verify the satellite server identitity. If not provided, the local Puppet Enterprise master's CA is used. Default: `/etc/puppetlabs/puppet/ssl/ca/katello-default-ca.crt`.

* `ssl_cert` - The file path to the certificate signed by the Satellite CA. This is used for Satellite to verify the identity of the Puppet Enterprise master. Default: `/etc/puppetlabs/puppet/ssl/certs/$(satellite_fqdn).pem`.

* `ssl_key` - The file path to the key generated by Satellite for the Puppet Enterprise master. Default: `/etc/puppetlabs/puppet/ssl/certs/$(pe_master_fqdn).pem`

* `verify_satellite_certificate` - When set to true, allows the Satellite server to present an unsigned, unrecognised, or invalid ssl certificate. Valid values: true, false. Defaults to true.

## Limitations

The pe_satellite module requires Red Hat Satellite 6 and Puppet Enterprise 3.8.1 or later. This module is supported on: 

* Red Hat 7
* CentOS 7
* Oracle Linux 7
* Scientific Linux 7

## Development

This module was built by Puppet Labs specifically for use with Puppet Enterprise (PE).

If you run into an issue with this module, or if you would like to request a feature, please [file a ticket](https://tickets.puppetlabs.com/browse/MODULES/).

If you are having problems getting this module up and running, please [contact Support](http://puppetlabs.com/services/customer-support).