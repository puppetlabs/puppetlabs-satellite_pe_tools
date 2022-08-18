# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v4.1.0](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/v4.1.0) (2022-08-18)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/v4.0.2...v4.1.0)

### Added

- \(maint\) Raise upper bound of stdlib [\#189](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/189) ([david22swan](https://github.com/david22swan))

## [v4.0.2](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/v4.0.2) (2022-07-18)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/v4.0.1...v4.0.2)

### Fixed

- \(MAINT\) Bump stdlib version [\#187](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/187) ([chelnak](https://github.com/chelnak))
- report processor: load utils via absolute path [\#180](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/180) ([bastelfreak](https://github.com/bastelfreak))

## [v4.0.1](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/v4.0.1) (2021-03-29)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/v4.0.0...v4.0.1)

### Fixed

- Fix "Could not send report to Satellite: undefined method `each\_value' for Puppet::Util::Metric" [\#160](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/160) ([DavidS](https://github.com/DavidS))

## [v4.0.0](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/v4.0.0) (2021-02-27)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/v3.1.0...v4.0.0)

### Changed

- pdksync - Remove Puppet 5 from testing and bump minimal version to 6.0.0 [\#149](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/149) ([carabasdaniel](https://github.com/carabasdaniel))

### Added

- pdksync - \(feat\) - Add support for Puppet 7 [\#142](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/142) ([daianamezdrea](https://github.com/daianamezdrea))

### Fixed

- \(IAC-1008\) - Removal of Inappropriate Terminology [\#148](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/148) ([david22swan](https://github.com/david22swan))
- Update satellite.rb [\#139](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/139) ([eppini](https://github.com/eppini))

## [v3.1.0](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/v3.1.0) (2019-12-09)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/v3.0.0...v3.1.0)

### Added

- FM-8032 - add redhat8 support [\#112](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/112) ([lionce](https://github.com/lionce))

## [v3.0.0](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/v3.0.0) (2019-05-16)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/2.3.0...v3.0.0)

### Changed

- pdksync - \(MODULES-8444\) - Raise lower Puppet bound [\#103](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/103) ([david22swan](https://github.com/david22swan))

### Added

- \(FM-7937\) Implement Puppet Strings [\#107](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/107) ([carabasdaniel](https://github.com/carabasdaniel))

## [2.3.0](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/2.3.0) (2019-02-11)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/2.2.0...2.3.0)

### Fixed

- Updated license terms [\#89](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/89) ([turbodog](https://github.com/turbodog))
- pdksync - \(FM-7655\) Fix rubygems-update for ruby \< 2.3 [\#86](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/86) ([tphoney](https://github.com/tphoney))
- \(FM-7529\) - Updating metadata to reflect support [\#82](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/82) ([pmcmaw](https://github.com/pmcmaw))

## [2.2.0](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/2.2.0) (2018-09-27)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/2.1.0...2.2.0)

### Added

- pdksync - \(MODULES-6805\) metadata.json shows support for puppet 6 [\#75](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/75) ([tphoney](https://github.com/tphoney))

## 2.1.0
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


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
