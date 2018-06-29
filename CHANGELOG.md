## Supported Release 2.1.0
### Summary
This is a minor release that includes changes to make this module compatible with 2018.1 and `pdk`. It also contains a roll up of minor changes and maintenance.

#### Added
- Converted with PDK 1.5.0, this module is now compatible with `pdk`.
- Updated facts_terminus_scripts to run on 2018.1.

##### Changed
- Bumped 'puppetlabs-inifile' upper boundary from 2.0.0 to 3.0.0.

#### Fixed
- Put 'puppetlabs-stdlib' into fixtures to address unit tests failures.
- Update docs for satellite 6 tarball-of-rpms certs.

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
