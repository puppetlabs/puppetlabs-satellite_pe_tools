# == Class: satellite_pe_tools
#
# This module provides and configures a report processor to send puppet agent reports
# to a Satellite server
#
# === Parameters
#
# [*satellite_url*]
#   The full URL to the satellite server in format https://url.to.satellite
#
# [*ssl_ca*]
#   Optional. The file path to the CA certificate used to verify the satellite server
#   identitity. If not provided, the local Puppet Enterprise master's CA is used.
#
# [*ssl_cert*]
#   The file path to the certificate signed by the Satellite CA. It's used for Satellite
#   to verify the identity of the Puppet Enterprise master
#
# [*ssl_key*]
#   The file path to the key for the Puppet Enterprise master generated by Satellite
#
# === Examples
#
#  class { 'satellite_pe_tools':
#    satellite_url => 'https://satellite.example.domain',
#    ssl_ca        => '/etc/puppetlabs/puppet/ssl/ca/katello-default-ca.crt',
#    ssl_cert      => '/etc/puppetlabs/puppet/ssl/certs/satellite-master.example.domain.pem',
#    ssl_key       => '/etc/puppetlabs/puppet/ssl/private_keys/master.domain.com.pem',
#  }
#
# === Authors
#
# Puppet Labs <info@puppetlabs.com>
#
# === Copyright
#
# Copyright 2015 Puppet Labs
class satellite_pe_tools(
  $satellite_url,
  $verify_satellite_certificate = true,
  $ssl_ca                       = '',
  $ssl_cert                     = '',
  $ssl_key                      = '',
  $manage_default_ca_cert       = true,
) {

  $parsed_hash = parse_url($satellite_url)
  $satellite_hostname = $parsed_hash['hostname']

  if $verify_satellite_certificate {
    if $ssl_ca != '' {
      $ssl_ca_real = $ssl_ca
    } else {
      $ssl_ca_real = '/etc/puppetlabs/puppet/ssl/ca/katello-default-ca.crt'
    }
  } else {
    $ssl_ca_real = false
  }

  $satellite_config = {
    url      => $satellite_url,
    ssl_ca   => $ssl_ca_real,
    ssl_cert => $ssl_cert,
    ssl_key  => $ssl_key,
  }

  pe_ini_subsetting { 'reports_satellite' :
    ensure               => present,
    path                 => "${::settings::confdir}/puppet.conf",
    section              => 'master',
    setting              => 'reports',
    subsetting           => 'satellite',
    subsetting_separator => ',',
    notify               => Service['pe-puppetserver'],
    before               => File['satellite_config_yaml'],
  }

  file { 'satellite_config_yaml':
    ensure  => file,
    path    => '/etc/puppetlabs/puppet/satellite_pe_tools.yaml',
    content => to_yaml($satellite_config),
    owner   => pe-puppet,
    group   => pe-puppet,
    mode    => '0644',
    notify  => Service['pe-puppetserver'],
  }

  if ($manage_default_ca_cert) and ($::osfamily == 'RedHat') {
    exec {'download_install_katello_cert_rpm':
      path    => ['/usr/bin', '/bin',],
      command => "curl -k -o /tmp/katello-ca-consumer-latest.noarch.rpm ${satellite_url}/pub/katello-ca-consumer-latest.noarch.rpm && yum -y install /tmp/katello-ca-consumer-latest.noarch.rpm",
      creates => '/etc/rhsm/ca/katello-server-ca.pem',
    }

    file { '/etc/puppetlabs/puppet/ssl/ca/katello-default-ca.crt':
      ensure  => 'link',
      target  => '/etc/rhsm/ca/katello-server-ca.pem',
      require => Exec['download_install_katello_cert_rpm'],
      before  => File['satellite_config_yaml'],
    }
  }
}
