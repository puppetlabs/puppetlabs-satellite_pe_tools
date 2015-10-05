# satellite_pe_tools

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with satellite_pe_tools](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with satellite_pe_tools](#beginning-with-satellite_pe_tools)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

The satellite_pe_tools module configures Puppet's report processor and facts indirector to allow you to send Puppet reports and facts to your Red Hat Satellite server.

## Setup

### Setup requirements

This module requires Puppet Enterprise 3.8.1 or later.

### Beginning with satellite_pe_tools

1. [Classify Puppet Enterprise masters](#classify-puppet-enterprise-masters)
2. [Set PE master facts terminus](#set-pe-master-facts-terminus)
3. [Allow PE master to send data to Satellite](#allow-pe–master-to-send-data-to-satellite)
4. [Allow PE Master to verify Satellite server identity](#allow-pe-master-to-verify-satellite-server-identity)
5. [Allow Satellite server to verify PE Master identity](#allow-satellite-server-to-verify-pe-master-identity)
6. [Enable pluginsync and reports in Puppet](#enable-pluginsync-and-reports-in-puppet)

To set up communication between Satellite and your PE masters, follow these steps:

1. Classify Puppet Enterprise masters

   Add the `satellite_pe_tools` class to the PE Master node group in the Puppet Enterprise Console. For details on adding classes to node groups, see the [Puppet Enterprise documentation](https://docs.puppetlabs.com/pe/latest/console_classes_groups.html#adding-classes-to-a-node-group).

2. Set PE Master facts terminus

  In the PE Master node group in the PE Console, add the `facts_terminus`
parameter to the `puppet_enterprise::profile::master` class with a string value of 'satellite'.
This sets Puppet runs on PE masters to forward the facts to Satellite.

3. Allow the PE Master to verify the Satellite server's identity

  To use SSL verification so that the Puppet master can verify the satellite server, which prevents man-in-the-middle attacks, the Certificate Authority (CA) certificate that signed the Satellite server's SSL certificate must be available on the Puppet Enterprise master.

  By default, the CA certificate is located on the Satellite CA server. On Red Hat based systems,
  this is automatically managed by the module. Note: The CA cert is transferred over an untrusted SSL connection. If you wish to transfer the cert manually, please see below. You must also set the `manage_default_ca_cert` parameter to false. 

  On non-Red Hat systems (or if you wish to manually transfer the cert), copy the file `/etc/pki/katello/certs/katello-default-ca.crt` from the Satellite CA server to `/etc/puppetlabs/puppet/ssl/ca/katello-default-ca.crt` on each PE master. Note that if you place the certificate in a different location or give it a different name, you must set the `ssl_ca` parameter for the `satellite_pe_tools` class to the file path of the CA certificate.

  Alternatively, if the Satellite SSL certificate is signed by a remote CA, copy the remote CA's certificate to each PE master and set the `ssl_ca` parameter for the `satellite_pe_tools` class to the file path of the CA certificate.

  If you do not wish to verify the identity of the Satellite server, you can set the[`verify_satellite_certificate`](#verify_satellite_certificate) parameter for the `satellite_pe_tools` class to false.
  
4. Allow the Satellite server to verify the PE Master's identity

  By default, Satellite is configured to verify the SSL identity of the Puppet
  Enterprise masters connecting to it. If the PE report processor and facts indirector are not using a certificate signed with the Satellite server's CA, the verification fails.
  
  To use SSL verification so that the Satellite server can verify the PE Master, you must generate a SSL cert and key pair on the Satellite server, and then copy these files to your PE master.

  Note: In the following steps, 'satellite.example.com' should be replaced by the FQDN of your PE Master.

  4a. On the Satellite server, run the following command: `capsule-certs-generate --capsule-fqdn "satellite.example.com --certs-tar "~/satellite.example.com-certs.tar"`

  4b. Untar the newly created file: `tar -xvf ~/satellite.example.com-certs.tar`. A new folder `~/ssl-build` will be created.

  4c. Copy the following 2 files over to your PE Master: `~/ssl-build/satellite.example.com/satellite.example.com-puppet-client.crt` and `~/ssl-build/satellite.example.com/satellite.example.com-puppet-client.key`. A good place to copy them is to `/etc/puppetlabs/puppet/ssl/satellite` (version 2015.x) or `/etc/puppet/ssl/satellite` (version 3.x) on your PE Master.

  4d. On your PE Master, set the ownership of these 2 files to `pe-puppet`. 

  Example (Adjust paths and filenames accordingly):
  ~~~puppet
  chown pe-puppet /etc/puppetlabs/puppet/ssl/satellite/satellite.example.com-puppet-client.crt
  chown pe-puppet /etc/puppetlabs/puppet/ssl/satellite/satellite.example.com-puppet-client.key
  ~~~

  4e. In the Satellite UI, go to *Administer -> Settings -> Auth* and set the `restrict_registered_puppetmasters` parameter to true. Additionally, add your PE Master's FQDN to the `trusted_puppetmaster_hosts` array on the same page - E.g. `[satellite.example.com]`

  4f. Set the `ssl_cert` and `ssl_key` parameters in your `satellite_pe_tools` class to the location on your PE Master of the 2 files respectively.

  If you do not wish for the Satellite server to verify the PE Master identity, in the Satellite UI, go to *Administer -> Settings -> Auth* and set the `restrict_registered_puppetmasters` parameter to false.

  Note that this setting presents a security risk, as false reports and facts can be sent to Satellite by a malicious system masquerading as a current PE master on your infrastructure that's been added to Satellite as a safe PE master.

5. Enable pluginsync and reports in Puppet

  On each Puppet agent, make sure the [`pluginsync`](https://docs.puppetlabs.com/references/latest/configuration.html#pluginsync) and [`report`](https://docs.puppetlabs.com/references/latest/configuration.html#report) settings are enabled. (These settings are normally enabled by default.)

        [agent]
        report = true
        pluginsync = true

## Usage
        
~~~puppet
class {'satellite_pe_tools':
	satellite_url => "https://satellite.example.com",
    verify_satellite_certificate => true,
}
~~~

This example tells the PE master the location of the Satellite server (`https://satellite.example.com`) and instructs it to verify the Satellite server's identity. 

## Debugging

As well as looking through the usual reports via the Puppet Enterprise Console, you can also view the Satellite API log file which may provide clues as to what a paticular issue may be. This file is located at `/var/log/httpd/foreman-ssl_access_ssl.log` on your Satellite server.

An example of a SSL authentication failure (Note the '403'):
~~~puppet
10.32.125.164 - - [03/Oct/2015:16:06:19 -0700] "POST /api/reports HTTP/1.1" 403 58 "-" "Ruby"
~~~

An example of a sucessful SSL authentication (Note the '201'):
~~~puppet
10.32.125.164 - - [03/Oct/2015:16:06:00 -0700] "POST /api/reports HTTP/1.1" 201 554 "-" "Ruby"
~~~

## Reference

### Class: satellite_pe_tools

The only class of the module, `satellite_pe_tools` configures Puppet's report
processor and facts indirector to communicate with Satellite.

#### Parameters

All parameters are **required** unless otherwise specified.

* `manage_default_ca_cert` - Applicable to Red Hat based systems only. When set to true, the module will transfer the Satellite server's default CA certificate from the satellite server to the PE master. This uses an untrusted SSL connection. Defaults to true.

* `satellite_url` - The full URL to the satellite server in format `https://url.to.satellite`.

* `ssl_ca` - The file path to the CA certificate used to verify the satellite server identitity. Not used if `verify_satellite_certificate` is set to false. Default: `/etc/puppetlabs/puppet/ssl/ca/katello-default-ca.crt`.

* `ssl_cert` - The file path to the certificate signed by the Satellite CA. This is required for Satellite to verify the identity of the Puppet Enterprise master.

* `ssl_key` - The file path to the key generated by Satellite for the Puppet Enterprise master. This is required for Satellite to verify the identity of the Puppet Enterprise master.

* `verify_satellite_certificate` - When set to false, allows the Satellite server to present an unsigned, unrecognised, or invalid SSL certificate. This opens up the possibility of a host falsifying its identity as the Satellite server. Valid values: true, false. Defaults to true.

## Limitations

The satellite_pe_tools module requires Red Hat Satellite 6 and Puppet Enterprise 3.8.1 or later. This module is supported on:

* Red Hat 7
* CentOS 7
* Oracle Linux 7
* Scientific Linux 7

## Development

This module was built by Puppet Labs specifically for use with Puppet Enterprise (PE).

If you run into an issue with this module, or if you would like to request a feature, please [file a ticket](https://tickets.puppetlabs.com/browse/MODULES/).

If you are having problems getting this module up and running, please [contact Support](http://puppetlabs.com/services/customer-support).
