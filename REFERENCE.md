# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

* [`satellite_pe_tools`](#satellite_pe_tools): This module provides and configures a report processor to send puppet agent reports
to a Satellite server

### Functions

* [`parse_url`](#parse_url)
* [`to_yaml`](#to_yaml)

### Plans

* [`satellite_pe_tools::test_01_provision`](#satellite_pe_tools--test_01_provision)
* [`satellite_pe_tools::test_02_server_setup`](#satellite_pe_tools--test_02_server_setup)
* [`satellite_pe_tools::test_03_test_run`](#satellite_pe_tools--test_03_test_run)

## Classes

### <a name="satellite_pe_tools"></a>`satellite_pe_tools`

This module provides and configures a report processor to send puppet agent reports
to a Satellite server

#### Examples

##### 

```puppet
class { 'satellite_pe_tools':
  satellite_url => 'https://satellite.example.domain',
  ssl_ca        => '/etc/puppetlabs/puppet/ssl/ca/katello-default-ca.crt',
  ssl_cert      => '/etc/puppetlabs/puppet/ssl/certs/satellite-server.example.domain.pem',
  ssl_key       => '/etc/puppetlabs/puppet/ssl/private_keys/puppet.domain.com.pem',
}
```

#### Parameters

The following parameters are available in the `satellite_pe_tools` class:

* [`satellite_url`](#-satellite_pe_tools--satellite_url)
* [`verify_satellite_certificate`](#-satellite_pe_tools--verify_satellite_certificate)
* [`ssl_ca`](#-satellite_pe_tools--ssl_ca)
* [`ssl_cert`](#-satellite_pe_tools--ssl_cert)
* [`ssl_key`](#-satellite_pe_tools--ssl_key)
* [`manage_default_ca_cert`](#-satellite_pe_tools--manage_default_ca_cert)

##### <a name="-satellite_pe_tools--satellite_url"></a>`satellite_url`

Data type: `String`

The full URL to the satellite server in format https://url.to.satellite

##### <a name="-satellite_pe_tools--verify_satellite_certificate"></a>`verify_satellite_certificate`

Data type: `Boolean`

When set to false, allows the Satellite server to present an unsigned, unrecognized,
or invalid SSL certificate. This creates the risk of a host falsifying its identity as the Satellite server.
Valid values: true, false.

Default value: `true`

##### <a name="-satellite_pe_tools--ssl_ca"></a>`ssl_ca`

Data type: `Optional[String[1]]`

The file path to the CA certificate used to verify the satellite server identitity. If not
provided, the local Puppet Enterprise server's CA is used.

Default value: `undef`

##### <a name="-satellite_pe_tools--ssl_cert"></a>`ssl_cert`

Data type: `Optional[String[1]]`

The file path to the certificate signed by the Satellite CA. It's used for Satellite to verify the identity
of the Puppet Enterprise server

Default value: `undef`

##### <a name="-satellite_pe_tools--ssl_key"></a>`ssl_key`

Data type: `Optional[String[1]]`

The file path to the key for the Puppet Enterprise server generated by Satellite

Default value: `undef`

##### <a name="-satellite_pe_tools--manage_default_ca_cert"></a>`manage_default_ca_cert`

Data type: `Boolean`

Applicable to Red Hat-based systems only. When set to true, the module transfers the Satellite
server's default CA certificate from the Satellite server to the server. This uses an untrusted SSL connection.

Default value: `true`

## Functions

### <a name="parse_url"></a>`parse_url`

Type: Ruby 3.x API

The parse_url function.

#### `parse_url()`

The parse_url function.

Returns: `Any` This function parses a given URL and provides a hash of the parsed data.

### <a name="to_yaml"></a>`to_yaml`

Type: Ruby 3.x API

The to_yaml function.

#### `to_yaml()`

The to_yaml function.

Returns: `Any` This function takes a data structure and turns it into yaml

## Plans

### <a name="satellite_pe_tools--test_01_provision"></a>`satellite_pe_tools::test_01_provision`

The satellite_pe_tools::test_01_provision class.

### <a name="satellite_pe_tools--test_02_server_setup"></a>`satellite_pe_tools::test_02_server_setup`

The satellite_pe_tools::test_02_server_setup class.

### <a name="satellite_pe_tools--test_03_test_run"></a>`satellite_pe_tools::test_03_test_run`

The satellite_pe_tools::test_03_test_run class.

