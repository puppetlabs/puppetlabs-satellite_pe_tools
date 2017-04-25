## Supported Release 2.0.0
### Summary
This is a major Puppet 4-only release that installs Redhat Satellite 6.2.

#### Added
- Puppet 4 data types
- PE 2016.4 (LTS), 2016.5, and 2017.1 support
- beaker-pe development dependency

#### Changed
- switched from puppetlabs-pe_inifile to puppetlabs-inifile dependency
- updated puppetlabs-stdlib dependency to 4.13.0

#### Fixed
- Acceptance tests updated and fixed for PE versions listed above.

## Supported Release 1.0.1
### Summary

Small release for support of newer PE versions. This increments the version of PE in the metadata.json file.

## 2015-10-06 - Release 1.0.0
### Summary

This is the initial release of the puppetlabs-satellite_pe_tools module.

#### Features
- Send reports from PE to Satellite
- Send facts from PE to Satellite
- Management of default Satellite CA certificate
- Management of reports setting inside puppet.conf
