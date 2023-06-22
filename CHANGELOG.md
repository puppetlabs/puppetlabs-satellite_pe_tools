<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v4.2.0](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/v4.2.0) - 2023-06-22

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/v4.1.0...v4.2.0)

### Added

- pdksync - (MAINT) - Allow Stdlib 9.x [#208](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/208) ([LukasAud](https://github.com/LukasAud))

## [v4.1.0](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/v4.1.0) - 2023-02-10

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/v4.0.2...v4.1.0)

### Added

- (maint) Raise upper bound of stdlib [#189](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/189) ([david22swan](https://github.com/david22swan))

### Fixed

- (CONT-364) Syntax update [#196](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/196) ([LukasAud](https://github.com/LukasAud))

## [v4.0.2](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/v4.0.2) - 2022-07-18

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/v4.0.1...v4.0.2)

### Fixed

- (MAINT) Bump stdlib version [#187](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/187) ([chelnak](https://github.com/chelnak))
- report processor: load utils via absolute path [#180](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/180) ([bastelfreak](https://github.com/bastelfreak))

## [v4.0.1](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/v4.0.1) - 2021-03-29

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/v4.0.0...v4.0.1)

### Fixed

- Fix "Could not send report to Satellite: undefined method `each_value' for Puppet::Util::Metric" [#160](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/160) ([DavidS](https://github.com/DavidS))

## [v4.0.0](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/v4.0.0) - 2021-03-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/v3.1.0...v4.0.0)

### Added

- pdksync - (feat) - Add support for Puppet 7 [#142](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/142) ([daianamezdrea](https://github.com/daianamezdrea))

### Changed
- pdksync - Remove Puppet 5 from testing and bump minimal version to 6.0.0 [#149](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/149) ([carabasdaniel](https://github.com/carabasdaniel))

### Fixed

- (IAC-1008) - Removal of Inappropriate Terminology [#148](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/148) ([david22swan](https://github.com/david22swan))
- Update satellite.rb [#139](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/139) ([eppini](https://github.com/eppini))

## [v3.1.0](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/v3.1.0) - 2019-12-10

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/v3.0.0...v3.1.0)

### Added

- FM-8032 - add redhat8 support [#112](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/112) ([lionce](https://github.com/lionce))

## [v3.0.0](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/v3.0.0) - 2019-05-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/2.3.0...v3.0.0)

### Added

- (FM-7937) Implement Puppet Strings [#107](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/107) ([carabasdaniel](https://github.com/carabasdaniel))

### Changed
- pdksync - (MODULES-8444) - Raise lower Puppet bound [#103](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/103) ([david22swan](https://github.com/david22swan))

## [2.3.0](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/2.3.0) - 2019-02-12

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/2.2.0...2.3.0)

### Fixed

- Updated license terms [#89](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/89) ([turbodog](https://github.com/turbodog))
- pdksync - (FM-7655) Fix rubygems-update for ruby < 2.3 [#86](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/86) ([tphoney](https://github.com/tphoney))
- (FM-7529) - Updating metadata to reflect support [#82](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/82) ([pmcmaw](https://github.com/pmcmaw))

## [2.2.0](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/2.2.0) - 2018-09-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/2.1.0...2.2.0)

### Added

- pdksync - (MODULES-6805) metadata.json shows support for puppet 6 [#75](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/75) ([tphoney](https://github.com/tphoney))

## [2.1.0](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/2.1.0) - 2018-07-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/2.0.0...2.1.0)

### Fixed

- (FM-7080) - Making 2018.1 compatible [#64](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/64) ([pmcmaw](https://github.com/pmcmaw))

## [2.0.0](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/2.0.0) - 2017-05-02

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/1.0.1...2.0.0)

### Added

- (MODULES-4758) Update satellite for Puppet 4 [#45](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/45) ([eputnam](https://github.com/eputnam))

## [1.0.1](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/1.0.1) - 2015-12-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/1.0.0...1.0.1)

### Fixed

- Restart Puppet Server on config change [#24](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/24) ([ccaum](https://github.com/ccaum))

## [1.0.0](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/tree/1.0.0) - 2015-10-06

[Full Changelog](https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/compare/f3d06a4a68843803055f0da72b4f57fe18b8089f...1.0.0)
