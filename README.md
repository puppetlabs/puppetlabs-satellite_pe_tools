# Set Up Steps

* [Classify Puppet Enterprise Masters](#Classify-Puppet-Enterprise-Masters)
* [Allow Puppet Enterprise Master to Send Data to Satellite](#Allow-Puppet-Enterprise–Master-to-Send-Data-to-Satellite)
* [Satellite Server Identity Verification](#Satellite-Server-Identify-Verification)

# Classify Puppet Enterprise Masters

Make sure this module has been installed in the production environment's
modulepath by directly installing it to the correct location, or use r10k by
adding it to your Puppetfile in the production branch.

This module provides one class, *pe_satellite* that configures the report
processor and facts indirector to know how to communicate with Satellite.

The *pe_satellite* class should be added to the PE Master node group in the
Puppet Enterprise Console.

The following parameters are available:

|parameter|description|default value|require|
|---------|-----------|-------------|-------|
| satellite_url | The full URL to the satellite host|  | yes |
| verify_satellite_certificate | Whether or not to verify the Satellite server's identitify | true | no |
| ssl_ca | The file path to the Satellite Server's CA certificate | /etc/puppetlabs/puppet/ssl/ca/katello-default-ca.crt | no |
| ssl_cert | The file path to the PE Master's certificate signed with the Satellite server's CA certificate | /etc/puppetlabs/puppet/ssl/certs/$(satellite_fqdn).pem | no |
| ssl_key | The file path to the PE Master's private key used to generate the PE Master's  | /etc/puppetlabs/puppet/ssl/certs/$(pe_master_fqdn).pem | no |

## Set PE Master Facts Terminus

**Note: This setting is only available in PE 3.8.1+. See ticket [#PE-9933](https://tickets.puppetlabs.com/browse/PE-9933)**

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

## Parameters

* `satellite_url` - The full URL to the satellite server in format https://url.to.satellite

* `ssl_ca` - Optional. The file path to the CA certificate used to verify the satellite server identitity. If not provided, the local Puppet Enterprise master's CA is used.

* `ssl_cert` - The file path to the certificate signed by the Satellite CA. It's used for Satellite to verify the identity of the Puppet Enterprise master

* `ssl_key` - The file path to the key for the Puppet Enterprise master generated by Satellite

* `verify_satellite_certificate` - When set to true, this allows the satellite server to present an unsigned, unrecognised, or invalid ssl certificate. Defaults to true

## Supported

Supports Puppet Enterprise 2015.2.x running on Red Hat 7, CentOS 7, Oracle Linux 7 and Scientific Linux 7.
Requires Red Hat Satellite 6
