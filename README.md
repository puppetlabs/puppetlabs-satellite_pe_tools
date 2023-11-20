# satellite_pe_tools

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with satellite_pe_tools](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with satellite_pe_tools](#beginning-with-satellite_pe_tools)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [License](#license)
7. [Development - Guide for contributing to the module](#development)

## Description

The `satellite_pe_tools` module configures Puppet's report processor and facts indirector to allow you to send Puppet reports and facts to your Red Hat Satellite server.

## Setup

### Setup requirements

This module requires Red Hat Satellite 6.13 and Puppet Enterprise (PE) 2021.7.4 or later.

### Beginning with satellite_pe_tools

1. [Classify Puppet servers](#classify-puppet-servers)
2. [Set Puppet server facts terminus](#set-puppet-server-facts-terminus)
3. [Allow Puppet server to send data to Satellite](#allow-puppet–server-to-send-data-to-satellite)
4. [Allow Puppet server to verify Satellite server identity](#allow-puppet-server-to-verify-satellite-server-identity)
5. [Allow Satellite server to verify Puppet server identity](#allow-satellite-server-to-verify-puppet-server-identity)
6. [Enable pluginsync and reports in Puppet](#enable-pluginsync-and-reports-in-puppet)

To set up communication between Satellite and your Puppet servers, follow these steps:

1. Classify Puppet servers

   Add the `satellite_pe_tools` class to the PE server node group in the PE Console. For details on adding classes to node groups, see the [Puppet Enterprise documentation](https://docs.puppet.com/pe/latest/console_classes_groups.html#adding-classes-to-a-node-group).

2. Set Puppet server facts terminus

   In the PE server node group in the PE Console, add the `facts_terminus`
parameter to the `puppet_enterprise::profile::server` class with a string value of 'satellite'. This sets Puppet runs on your Puppet servers to forward the facts to Satellite.

3. Allow the Puppet server to verify the Satellite server's identity

   To use SSL verification so that the Puppet server can verify the Satellite server (to prevents man-in-the-middle attacks), the Certificate Authority (CA) certificate that signed the Satellite server's SSL certificate must be available on the Puppet server.

   By default, the CA certificate is located on the Satellite CA server. On Red Hat-based systems, this is automatically managed by the module. Note that the CA cert is transferred over an untrusted SSL connection. If you wish to transfer the cert manually, see below. You must also set the `manage_default_ca_cert` parameter to `false`.

   On non-Red Hat systems, or if you wish to manually transfer the cert, copy the file `/etc/pki/katello/certs/katello-default-ca.crt` from the Satellite CA server to `/etc/puppetlabs/puppet/ssl/ca/katello-default-ca.crt` on each Puppet server. If you place the certificate in a different location or give it a different name, you must set the `ssl_ca` parameter for the `satellite_pe_tools` class to the file path of the CA certificate.

   If the Satellite SSL certificate is signed by a remote CA, copy the remote CA's certificate to each Puppet server, and then set the `ssl_ca` parameter for the `satellite_pe_tools` class to the file path of the CA certificate.

   If you do not wish to verify the identity of the Satellite server, you can set the [`verify_satellite_certificate`](#verify_satellite_certificate) parameter for the `satellite_pe_tools` class to `false`.

4. Allow the Satellite server to verify the Puppet server's identity

   By default, Satellite is configured to verify the SSL identity of the PE servers connecting to it. If the PE report processor and facts indirector are not using a certificate signed with the Satellite server's CA, the verification fails.

   To use SSL verification so that the Satellite server can verify the Puppet server, you must generate a SSL cert and key pair on the Satellite server, and then copy these files to your Puppet server.

> Note: In the following steps, replace `puppet.example.com` with the FQDN of your Puppet server.

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

d. Copy the `.crt` and `.key` files to your Puppet server, found either at:

`~/ssl-build/puppet.example.com/puppet.example.com-puppet-client.crt`

`~/ssl-build/puppet.example.com/puppet.example.com-puppet-client.key`

Or if you had to extract them from the RPM: 
   `~/ssl-build/puppet.example.com/etc/pki/katello-certs-tools/certs/puppet.example.com-puppet-client.crt`
     `~/ssl-build/puppet.example.com/etc/pki/katello-certs-tools/private/puppet.example.com-puppet-client.key`

Copy the files to `/etc/puppetlabs/puppet/ssl/satellite`.

e. On your Puppet server, set the ownership of these two files to `pe-puppet`:


Example (adjust paths and filenames accordingly):

```
chown pe-puppet /etc/puppetlabs/puppet/ssl/satellite/puppet.example.com-puppet-client.crt
chown pe-puppet /etc/puppetlabs/puppet/ssl/satellite/puppet.example.com-puppet-client.key
```

f. In the Satellite UI, go to *Administer -> Settings -> Auth* and set the `restrict_registered_smart_proxies` parameter to `Yes`. Additionally, add your Puppet server's FQDN to the `trusted_hosts` array on the same page; for example, `[puppet.example.com]`.

`trusted_hosts` has been given the label "Trusted hosts" in the UX. You can see the actual setting names by mousing over the label.

g. Set the `ssl_cert` and `ssl_key` parameters in your `satellite_pe_tools` class to the location on your Puppet server of the two files respectively.

If you do not want the Satellite server to verify the Puppet server identity, then in the Satellite UI, go to *Administer -> Settings -> Auth* and set the `restrict_registered_smart_proxies` parameter to `No`.

Note that this setting presents a security risk. False reports and facts can be sent to Satellite by a malicious system masquerading as a current Puppet server on your infrastructure that's been added to Satellite as a safe server.

5. Configure Satellite Service to onboading hosts
To onboard a host to the Satellite server, you will need to configure an activation key and two global variables:
`puppet_server= Puppet Master FQDN` 
`enable-puppet7=true`.
*Activation Key*
```
hammer --username <username> --password <password> activation-key create --name <activation-key-name> --unlimited-hosts --description 'Example Stack in the Development Environment' --lifecycle-environment 'Library' --content-view 'Default Organization View' --organization-label <organization_label_name>
```
*Global Parameters*
```
hammer --username admin --password puppetlabs global-parameter set --name puppet_server --value <Puppet-Server-FQDN>
hammer --username admin --password puppetlabs global-parameter set --name enable-puppet7 --value true
```

6. Enable reports in Puppet

On each Puppet agent, make sure the [`report`](https://www.puppet.com/docs/puppet/7/reporting_about.html) setting is enabled. This setting is usually enabled by default.

        [agent]
        report = true

## Usage

~~~puppet
class {'satellite_pe_tools':
  satellite_url                => "https://puppet.example.com",
  verify_satellite_certificate => true,
}
~~~

This example tells the Puppet server the location of the Satellite server (`https://puppet.example.com`) and instructs it to verify the Satellite server's identity.

## Debugging

In addition to the reports in the Puppet Enterprise Console, the Satellite API log and the Puppet server log can help you debug issues.

The Satellite API log file is located at `/var/log/httpd/foreman-ssl_access_ssl.log` on your Satellite server.

An example of a SSL authentication failure (note the '403'):

```puppet
10.32.125.164 - - [03/Oct/2015:16:06:19 -0700] "POST /api/reports HTTP/1.1" 403 58 "-" "Ruby"
```

An example of a sucessful SSL authentication (note the '201'):

```puppet
10.32.125.164 - - [03/Oct/2015:16:06:00 -0700] "POST /api/reports HTTP/1.1" 201 554 "-" "Ruby"
```

The Puppet server log file is located at `/var/log/puppetlabs/puppetserver/puppetserver.log` on your Puppet server. 

An example of a DH PARAMETER failure:

```puppet
2018-03-04 15:16:17,161 ERROR [qtp1111094392-103] [puppetserver] Puppet Could not send report to Satellite: Could not generate DH keypair
```

You can resolve this error by adding a DH PARAMETER block to the custom certificate on the Satellite server.

```bash
openssl dhparam 1024 >> /etc/pki/katello/certs/katello-apache.crt
satellite-maintain restart
```

## Reference
For information on the classes and types, see the [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/blob/main/REFERENCE.md)

## Limitations

The `satellite_pe_tools` module requires Red Hat Satellite 6.2 and Puppet Enterprise 2016.4 or later. 

For an extensive list of supported operating systems, see [metadata.json](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/blob/main/metadata.json)

## License

This codebase is licensed under the Apache2.0 licensing, however due to the nature of the codebase the open source dependencies may also use a combination of [AGPL](https://www.gnu.org/licenses/agpl-3.0.en.html), [BSD-2](https://opensource.org/license/bsd-2-claus), [BSD-3](https://opensource.org/license/bsd-3-claus), [GPL2.0](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html), [LGPL](https://opensource.org/license/lgpl-3-0/), [MIT](https://opensource.org/license/mit/) and [MPL](https://opensource.org/license/mpl-2-0/) Licensing.

## Development

This module was built by Puppet specifically for use with Puppet Enterprise (PE).

If you run into an issue with this module, or if you would like to request a feature, please [file a ticket](https://tickets.puppet.com/browse/MODULES/).

If you are having problems getting this module up and running, please [contact Support](http://puppet.com/services/customer-support).
