# pe_satellite

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with pe_satellite](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with pe_satellite](#beginning-with-pe_satellite)
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

1. [Classify Puppet Enterprise masters](#classify-puppet-enterprise-masters)
2. [Set PE master facts terminus](#set-pe-master-facts-terminus)
3. [Allow PE master to send data to Satellite](#allow-pe–master-to-send-data-to-satellite)
4. [Verify Satellite server identity](#verify-satellite-server-identity)
5. [Disable PE master identity verification](#disable-pe-master-identity-verification)
6. [Enable pluginsync and reports in Puppet](#enable-pluginsync-and-reports-in-puppet)

**Note:** Because Satellite is currently unable to sign certificates, this integration works only if you tell the Satellite server [not to verify the PE master identity](#disable-pe-master-identity-verification). This creates a risk that false reports and facts could be sent to Satellite from a malicious system masquerading as a current PE master on an infrastructure that's been added as trusted to Satellite.

To set up communication between Satellite and your PE masters, follow these steps:

1. Classify Puppet Enterprise masters

   Add the `pe_satellite` class to the PE Master node group in the Puppet Enterprise Console. For details on adding classes to node groups, see the [Puppet Enterprise documentation](#https://docs.puppetlabs.com/pe/latest/console_classes_groups.html#adding-classes-to-a-node-group).

2. Set PE Master facts terminus

  In the PE Master node group in the PE Console, add the `facts_terminus`
parameter to the `puppet_enterprise` class with a string value of 'satellite'.
This sets Puppet runs on PE masters to forward the facts to Satellite.

3. Allow PE master to send data to Satellite

  By default, the Satellite server only allows Satellite capsules and Smart
Proxies to send facts and reports to the Satellite server. To allow each PE master to send facts and reports: 
    
    1. In Satellite, go to **Administer -> Settings -> Auth**
    2. Add the hostname of each PE master to the `trusted_puppetmaster_hosts` parameter value's array.

4. Verify Satellite server identity

  To use SSL verification, which prevents man-in-the-middle attacks, the
Certificate Authority (CA) certificate that signed the Satellite server's SSL
certificate must be available on the Puppet Enterprise master.

  By default, the CA certificate is located on the Satellite CA server. Copy the file `/etc/pki/katello/certs/katello-default-ca.crt` from the Satellite CA server to `/etc/puppetlabs/puppet/ssl/ca/katello-default-ca.crt` on each PE master. Note that if you place the certificate in a different location or give it a different name, you must set the `ssl_ca` parameter for the `pe_satellite` class to the file path of the CA certificate.

  Alternatively, if the Satellite SSL certificate is signed by a remote CA, the remote's CA certificate needs to be in `/etc/puppetlabs/puppet/ssl/ca/ca-certificate.crt`. In this case, set the `ssl_ca` parameter for the `pe_satellite` class to the file path of the CA certificate.

  If you do not wish to verify the identity of the Satellite server, you can set the[`verify_satellite_certificate`](#verify_satellite_certificate) parameter for the `pe_satellite` class to false.
  
5. Disable PE master identity verification

  By default, Satellite is configured to verify the SSL identity of the Puppet
Enterprise masters connecting to it. If the PE report processor and facts indirector are not using a certificate signed with the Satellite server's CA, the verification fails. 

  Currently, Satellite is incapable of signing certificates. This means you must configure Satellite to *not* verify the Puppet master's identity. To do so, in the Satellite UI, go to *Administer -> Settings -> Auth* and set the `restrict_registered_puppetmasters` parameter to false.

  Note that this setting presents a security risk, as false reports and facts can be sent to Satellite by a malicious system masquerading as a current PE master on your infrastructure that's been added to Satellite as a safe PE master.

6. Enable pluginsync and reports in Puppet

  On each Puppet agent, make sure the [`pluginsync`](https://docs.puppetlabs.com/references/latest/configuration.html#pluginsync) and [`report`](https://docs.puppetlabs.com/references/latest/configuration.html#report) settings are enabled. (These settings are normally enabled by default.)

        [agent]
        report = true
        pluginsync = true

  On the Puppet master, make sure the [`reports`](https://docs.puppetlabs.com/references/4.2.latest/configuration.html#reports) setting in the master section includes pe_satellite:

        [master]
        reports = pe_satellite

## Usage
        
~~~puppet
class {'pe_satellite':
	satellite_url => "https://satellite.example.com",
    verify_satellite_certificate => true,
}
~~~

This example tells the PE master the location of the Satellite server (`https://satellite.example.com`) and instructs it to verify the Satellite server's identity. 


## Reference

### Class: pe_satellite

The only class of the module, `pe_satellite` configures Puppet's report
processor and facts indirector to communicate with Satellite.

#### Parameters

All parameters are **required** unless otherwise specified.

* `satellite_url` - The full URL to the satellite server in format `https://url.to.satellite`.

* `ssl_ca` - **Optional**. The file path to the CA certificate used to verify the satellite server identitity. If not provided, the local Puppet Enterprise master's CA is used. Default: `/etc/puppetlabs/puppet/ssl/ca/katello-default-ca.crt`.

* `ssl_cert` - The file path to the certificate signed by the Satellite CA. This is used for Satellite to verify the identity of the Puppet Enterprise master. Default: `/etc/puppetlabs/puppet/ssl/certs/$(satellite_fqdn).pem`.

* `ssl_key` - The file path to the key generated by Satellite for the Puppet Enterprise master. Default: `/etc/puppetlabs/puppet/ssl/certs/$(pe_master_fqdn).pem`

* `verify_satellite_certificate` - When set to false, allows the Satellite server to present an unsigned, unrecognised, or invalid SSL certificate. This opens up the possibility of a host falsifying its identity as the Satellite server. Valid values: true, false. Defaults to true.

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