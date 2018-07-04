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

The `satellite_pe_tools` module configures Puppet's report processor and facts indirector to allow you to send Puppet reports and facts to your Red Hat Satellite server.

## Setup

### Setup requirements

This module requires Red Hat Satellite 6.2 and Puppet Enterprise (PE) 2016.4 or later.

### Beginning with satellite_pe_tools

1. [Classify Puppet masters](#classify-puppet-masters)
2. [Set Puppet master facts terminus](#set-puppet-master-facts-terminus)
3. [Allow Puppet master to send data to Satellite](#allow-puppet–master-to-send-data-to-satellite)
4. [Allow Puppet master to verify Satellite server identity](#allow-puppet-master-to-verify-satellite-server-identity)
5. [Allow Satellite server to verify Puppet master identity](#allow-satellite-server-to-verify-puppet-master-identity)
6. [Enable pluginsync and reports in Puppet](#enable-pluginsync-and-reports-in-puppet)

To set up communication between Satellite and your Puppet masters, follow these steps:

1. Classify Puppet masters

   Add the `satellite_pe_tools` class to the PE master node group in the PE Console. For details on adding classes to node groups, see the [Puppet Enterprise documentation](https://docs.puppet.com/pe/latest/console_classes_groups.html#adding-classes-to-a-node-group).

2. Set Puppet master facts terminus

   In the PE master node group in the PE Console, add the `facts_terminus`
parameter to the `puppet_enterprise::profile::master` class with a string value of 'satellite'. This sets Puppet runs on your Puppet masters to forward the facts to Satellite.

3. Allow the Puppet master to verify the Satellite server's identity

   To use SSL verification so that the Puppet master can verify the Satellite server (to prevents man-in-the-middle attacks), the Certificate Authority (CA) certificate that signed the Satellite server's SSL certificate must be available on the Puppet master.

   By default, the CA certificate is located on the Satellite CA server. On Red Hat-based systems, this is automatically managed by the module. Note that the CA cert is transferred over an untrusted SSL connection. If you wish to transfer the cert manually, see below. You must also set the `manage_default_ca_cert` parameter to `false`.

   On non-Red Hat systems, or if you wish to manually transfer the cert, copy the file `/etc/pki/katello/certs/katello-default-ca.crt` from the Satellite CA server to `/etc/puppetlabs/puppet/ssl/ca/katello-default-ca.crt` on each Puppet master. If you place the certificate in a different location or give it a different name, you must set the `ssl_ca` parameter for the `satellite_pe_tools` class to the file path of the CA certificate.

   If the Satellite SSL certificate is signed by a remote CA, copy the remote CA's certificate to each Puppet master, and then set the `ssl_ca` parameter for the `satellite_pe_tools` class to the file path of the CA certificate.

   If you do not wish to verify the identity of the Satellite server, you can set the[`verify_satellite_certificate`](#verify_satellite_certificate) parameter for the `satellite_pe_tools` class to `false`.

4. Allow the Satellite server to verify the Puppet master's identity

   By default, Satellite is configured to verify the SSL identity of the PE masters connecting to it. If the PE report processor and facts indirector are not using a certificate signed with the Satellite server's CA, the verification fails.

   To use SSL verification so that the Satellite server can verify the Puppet master, you must generate a SSL cert and key pair on the Satellite server, and then copy these files to your Puppet master.

> Note: In the following steps, replace `puppet.example.com` with the FQDN of your Puppet master.

a. On the Satellite server, run the following command:

      ```
      capsule-certs-generate --capsule-fqdn "puppet.example.com" \
        --certs-tar "~/puppet.example.com-certs.tar"
      ```
> Note: Use `--foreman-proxy-fqdn` instead of `--capsule-fqdn` for Satellite 6.3

b. Untar the newly created file:

      ```
      tar -xvf ~/puppet.example.com-certs.tar
      ```

This creates a new folder: `~/ssl-build`. This may contain either raw `.crt` and `.key` file, or a number of RPM files.

c. If the ssl-build folder contains RPM files for the host, find and extract the contents of the puppet-client rpm file:

      ```
      cd ~/ssl-build/puppet.example.com
      rpm2cpio puppet.example.com-puppet-client-1.0-1.noarch.rpm | cpio -idmv
      ```

This creates a folder structure in the current directory beginning with `./etc/pki/katello-certs-tools/`

d. Copy the `.crt` and `.key` files to your Puppet master, found either at:

`~/ssl-build/puppet.example.com/puppet.example.com-puppet-client.crt`

`~/ssl-build/puppet.example.com/puppet.example.com-puppet-client.key`

Or if you had to extract them from the RPM: 
   `~/ssl-build/puppet.example.com/etc/pki/katello-certs-tools/certs/puppet.example.com-puppet-client.crt`
     `~/ssl-build/puppet.example.com/etc/pki/katello-certs-tools/private/puppet.example.com-puppet-client.key`

Copy the files to `/etc/puppetlabs/puppet/ssl/satellite` (on PE >= 2015.x) or `/etc/puppet/ssl/satellite` (PE 3.x) on your master.

e. On your Puppet master, set the ownership of these two files to `pe-puppet`:


Example (adjust paths and filenames accordingly):

      ~~~puppet
      chown pe-puppet /etc/puppetlabs/puppet/ssl/satellite/puppet.example.com-puppet-client.crt
      chown pe-puppet /etc/puppetlabs/puppet/ssl/satellite/puppet.example.com-puppet-client.key
      ~~~

f. In the Satellite UI, go to *Administer -> Settings -> Auth* and set the `restrict_registered_puppetmasters` parameter to `true`. Additionally, add your Puppet master's FQDN to the `trusted_puppetmaster_hosts` array on the same page; for example, `[puppet.example.com]`.

On Satellite 6.2 (and since Foreman 1.8.0) the `restrict_registered_puppetmasters` setting has been renamed to `restrict_registered_smart_proxies` (labelled "Restrict registered capsules"). `trusted_puppetmaster_hosts` has been given the label "Trusted puppetmaster hosts" in the UX. You can see the actual setting names by mousing over the label.

g. Set the `ssl_cert` and `ssl_key` parameters in your `satellite_pe_tools` class to the location on your Puppet master of the two files respectively.

If you do not want the Satellite server to verify the Puppet master identity, then in the Satellite UI, go to *Administer -> Settings -> Auth* and set the `restrict_registered_puppetmasters` parameter to `false`.

Note that this setting presents a security risk. False reports and facts can be sent to Satellite by a malicious system masquerading as a current Puppet master on your infrastructure that's been added to Satellite as a safe master.

5. Enable pluginsync and reports in Puppet

On each Puppet agent, make sure the [`pluginsync`](https://docs.puppet.com/latest/configuration.html#pluginsync) and [`report`](https://docs.puppet.com/latest/configuration.html#report) settings are enabled. These settings are usually enabled by default.

        [agent]
        report = true
        pluginsync = true

## Usage

~~~puppet
class {'satellite_pe_tools':
  satellite_url                => "https://puppet.example.com",
  verify_satellite_certificate => true,
}
~~~

This example tells the master the location of the Satellite server (`https://puppet.example.com`) and instructs it to verify the Satellite server's identity.

## Debugging

In addition to looking through the usual reports in the Puppet Enterprise Console, you can also view the Satellite API log file, which may provide clues as to what a particular issue may be. This file is located at `/var/log/httpd/foreman-ssl_access_ssl.log` on your Satellite server.

An example of a SSL authentication failure (note the '403'):

~~~puppet
10.32.125.164 - - [03/Oct/2015:16:06:19 -0700] "POST /api/reports HTTP/1.1" 403 58 "-" "Ruby"
~~~

An example of a sucessful SSL authentication (note the '201'):

~~~puppet
10.32.125.164 - - [03/Oct/2015:16:06:00 -0700] "POST /api/reports HTTP/1.1" 201 554 "-" "Ruby"
~~~

## Reference

### Class: satellite_pe_tools

The only class of the module, `satellite_pe_tools` configures Puppet's report processor and facts indirector to communicate with Satellite.

#### Parameters

###### `manage_default_ca_cert`

Data type: Boolean.

Applicable to Red Hat-based systems only. When set to `true`, the module transfers the Satellite server's default CA certificate from the Satellite server to the master. This uses an untrusted SSL connection.

Default: `true`.

###### `satellite_url`

Data type: String.

The full URL to the Satellite server in the format `https://url.to.satellite`.

###### `ssl_ca`

Data type: String.

The file path to the CA certificate used to verify the satellite server identity. Not used if `verify_satellite_certificate` is set to `false`.

Default: `/etc/puppetlabs/puppet/ssl/ca/katello-default-ca.crt`.

###### `ssl_cert`

Data type: String.

The file path to the certificate signed by the Satellite CA. This is required for Satellite to verify the identity of the Puppet master.

###### `ssl_key`

Data type: String.

The file path to the key generated by Satellite for the Puppet master. This is required for Satellite to verify the identity of the Puppet master.

###### `verify_satellite_certificate`

Data type: Boolean.

When set to `false`, allows the Satellite server to present an unsigned, unrecognized, or invalid SSL certificate. This creates the risk of a host falsifying its identity as the Satellite server.

Valid values: `true`, `false`.

Default: `true`.

## Limitations

The `satellite_pe_tools` module requires Red Hat Satellite 6.2 and Puppet Enterprise 2016.4 or later. This module is supported on:

* Red Hat Enterprise Linux 6, 7
* CentOS 6, 7
* Oracle Linux 7
* Scientific Linux 7

## Development

This module was built by Puppet specifically for use with Puppet Enterprise (PE).

If you run into an issue with this module, or if you would like to request a feature, please [file a ticket](https://tickets.puppet.com/browse/MODULES/).

If you are having problems getting this module up and running, please [contact Support](http://puppet.com/services/customer-support).
