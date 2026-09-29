# Changelog

All notable changes to this project are documented in this file, generated from
the project's original `parsec.changelog` and `webserver.changelog` files.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project does not follow Semantic Versioning strictly; version numbers are
historical and independent per component (`parsec.rb` and `webserver.rb`).

## Parsec (`parsec.rb`)

## [2.7.7] - 2026-09-29
### Changed
- Removed duplicate script-directory detection in `methods/common.rb`; it now reuses the `$script_dir` global already set by `parsec.rb`/`webserver.rb` instead of recomputing it independently

## [2.7.6] - 2026-09-29
### Fixed
- Fixed script directory detection in `methods/common.rb` (was `File.basename($0)`, should have been `File.dirname($0)`), which forced parsec.rb/webserver.rb to only work when invoked with the current directory equal to the repo root
- Fixed loading of `methods/*.rb` to resolve relative to the script's own directory instead of the current working directory
- Fixed `--input=<file>` to process the given file directly instead of re-deriving a hostname from its filename and searching `$exp_dir` for a match
- Fixed a crash (`NameError` on undefined `search_param`/`search_value`) when no explorer files match a `--server` search; now exits cleanly with "No explorer files found"

## [2.7.5] - 2026-09-29
### Added
- Added `CHANGELOG.md` (replacing `parsec.changelog`/`webserver.changelog`), `LICENSE`, `CLAUDE.md`, and `requirements.txt`
### Changed
- Updated license to CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike) from CC-BA (Attribution only)
### Fixed
- Fixed `--changelog` to print `CHANGELOG.md` (previously looked for a nonexistent file named `changelog`)

## [2.7.4] - 2019-04-20
### Fixed
- Fixed gem installation and imagemagick installation

## [2.7.3] - 2016-12-29
### Fixed
- Fixed star STDOUT capture on Amazon Linux

## [2.7.2] - 2016-12-28
### Fixed
- Fixed psrinfo report for Intel

## [2.7.1] - 2016-12-28
### Fixed
- Fixed bugs with SPEC and Power units reporting

## [2.7.0] - 2016-11-03
### Added
- Added ability to search by customer and some other fields to explorer list view

## [2.6.9] - 2016-10-10
### Added
- Added additional error handling for some reports

## [2.6.8] - 2016-09-23
### Fixed
- Fixed image inclusion in PDF report

## [2.6.7] - 2016-09-20
### Fixed
- Fixed memory report for V445

## [2.6.6] - 2016-09-19
### Fixed
- Fixed UTF8 error due to non ASCII characters and added power and rack unit calculations

## [2.6.5] - 2016-09-19
### Changed
- Improved data transfer calculations

## [2.6.4] - 2016-09-18
### Fixed
- Fixed bug with filesystem report on some systems

## [2.6.3] - 2016-09-18
### Added
- Added nocheck switch to ignore Security and other recommendations

## [2.6.2] - 2016-09-18
### Added
- Added ability to change logo and set partner name for PDF report

## [2.6.1] - 2016-09-18
### Fixed
- Fixed PDF report

## [2.6.0] - 2016-09-18
### Added
- Added simple psrinfo report

## [2.5.9] - 2016-09-17
### Added
- Added CPU model to host report

## [2.5.8] - 2016-09-17
### Added
- Added SPEC report

## [2.5.7] - 2016-09-17
### Changed
- Improved CPU report for T2 systems

## [2.5.6] - 2016-09-17
### Changed
- Improved CPU report on M7-8

## [2.5.5] - 2016-09-17
### Changed
- Improved hardware determination for listing

## [2.5.4] - 2016-09-17
### Changed
- Improved CPU report on T series

## [2.5.3] - 2016-09-16
### Added
- Added dfx report to estimate data transfer times

## [2.5.2] - 2016-09-16
### Fixed
- Fixed reporting for 'all' as a server name and using an explorer file as input

## [2.5.1] - 2016-09-15
### Removed
- Removed /platform from df report

## [2.5.0] - 2016-09-15
### Fixed
- Fixed CSV output

## [2.4.9] - 2016-09-15
### Added
- Added df report

## [2.4.8] - 2016-09-13
### Fixed
- Fixed Memory reporting for E450

## [2.4.7] - 2016-09-13
### Changed
- Improved ZFS pool reporting

## [2.4.6] - 2016-09-13
### Changed
- Improved CPU reporting

## [2.4.5] - 2016-09-13
### Fixed
- Fixed CPU report for V490

## [2.4.4] - 2016-09-12
### Added
- Improved handling of hostname search and added sds, cpus, disks and zone report name remap

## [2.4.3] - 2016-09-11
### Changed
- Improved sensor reporting on V440

## [2.4.2] - 2016-09-11
### Changed
- Improved valid report name test

## [2.4.1] - 2016-09-11
### Fixed
- Fixed FRU report on V240

## [2.4.0] - 2016-09-11
### Fixed
- Fixed network report

## [2.3.9] - 2016-09-11
### Changed
- Improved hardware quick lookup for V440 and V490

## [2.3.8] - 2016-09-11
### Added
- Added check for report type

## [2.3.7] - 2016-09-11
### Fixed
- Fixed zone output

## [2.3.6] - 2016-08-14
### Added
- Added initial MacOS install scripts

## [2.3.5] - 2016-08-14
### Changed
- Improved photo file name determination

## [2.3.4] - 2016-08-13
### Changed
- Improved table processing for PDF generation

## [2.3.3] - 2016-08-13
### Changed
- Improved crypto report output

## [2.3.2] - 2016-08-13
### Added
- Added code to pad table rows

## [2.3.1] - 2016-08-13
### Changed
- Improved PDF photo page creation

## [2.3.0] - 2016-08-13
### Fixed
- Fixed bug with OS build determination

## [2.2.9] - 2016-08-11
### Changed
- Photo file determination improvements

## [2.2.8] - 2016-08-11
### Fixed
- Fixed bug with photos code and some model header determination

## [2.2.7] - 2016-08-11
### Added
- Added photos

## [2.2.6] - 2016-08-09
### Added
- Added SSL support for webserver

## [2.2.5] - 2016-08-07
### Fixed
- Bug fixes

## [2.2.4] - 2016-08-07
### Fixed
- More output fixes

## [2.2.3] - 2016-08-07
### Fixed
- Output fixes

## [2.2.2] - 2016-08-07
### Changed
- Improved webserver output

## [2.2.1] - 2016-08-07
### Changed
- Moved global exp_info to common code so it's available for parsec and webserver

## [2.2.0] - 2016-08-07
### Changed
- Improved webserver output

## [2.1.9] - 2016-08-06
### Fixed
- More HTML output fixes

## [2.1.8] - 2016-08-06
### Fixed
- More HTML output fixes

## [2.1.7] - 2016-08-06
### Fixed
- HTML output fixes

## [2.1.6] - 2016-08-05
### Fixed
- Fixed IO output for webserver

## [2.1.5] - 2016-08-05
### Fixed
- Fixed bugs with aggr process

## [2.1.4] - 2016-08-05
### Fixed
- Fixed explorer listing

## [2.1.3] - 2016-08-05
### Added
- Added initial plumbing for sinatra web interface

## [2.1.2] - 2016-08-03
### Added
- Added basic wiki output capability

## [2.1.1] - 2016-08-02
### Changed
- Ongoing clean up of console output

## [2.1.0] - 2016-08-01
### Added
- Initial clean up of console output

## [2.0.9] - 2016-08-01
### Fixed
- Minor bug fixes

## [2.0.8] - 2016-07-30
### Removed
- Removed sysprop from all report on Solaris 11 to reduce report size

## [2.0.7] - 2016-07-30
### Fixed
- Fixes for Solaris

## [2.0.6] - 2016-07-23
### Fixed
- Minor bug fixes

## [2.0.5] - 2016-05-17
### Changed
- Improved sensor reporting for E250/E450

## [2.0.4] - 2016-05-17
### Changed
- Improved memory report for E250/E450

## [2.0.3] - 2016-05-16
### Added
- Added code to strip non ascii and control characters

## [2.0.2] - 2016-05-16
### Changed
- Minor improvements for VMware

## [2.0.1] - 2016-05-15
### Fixed
- Minor bug fix

## [2.0.0] - 2016-05-15
### Fixed
- Fixed bug with output directory creation

## [1.9.9] - 2016-05-15
### Fixed
- Minor fix to brew detection

## [1.9.8] - 2016-03-19
### Fixed
- Various fixes and support for T6340

## [1.9.7] - 2016-03-18
### Added
- Added SVM support

## [1.9.6] - 2016-03-17
### Changed
- Improved support 280R

## [1.9.5] - 2016-03-15
### Changed
- Improved explorer file search capability

## [1.9.4] - 2016-03-15
### Fixed
- Fixed hostname and date search for reports

## [1.9.3] - 2016-03-15
### Fixed
- Fixed bug with listing explorers

## [1.9.2] - 2016-03-07
### Added
- Added ability to list explorers based on a hostname search

## [1.9.1] - 2016-03-06
### Added
- Added --date and --year flag, and fixed ethernet address determination

## [1.9.0] - 2016-03-04
### Added
- Added code to convert CPU IDs array to string

## [1.8.9] - 2016-03-04
### Added
- Added hardware revision information to firmware report

## [1.8.8] - 2016-03-03
### Changed
- Improvements to IO report

## [1.8.7] - 2016-03-03
### Changed
- Improved IO report for T5440

## [1.8.6] - 2016-03-03
### Added
- Added support for T6300 sensors report

## [1.8.5] - 2016-03-03
### Added
- Added initial support for T6300 (IO report)

## [1.8.4] - 2016-03-03
### Fixed
- Fixed bug with FC firmware code detection

## [1.8.3] - 2016-03-03
### Changed
- Improved IO reporting on T2000

## [1.8.2] - 2016-03-03
### Changed
- Improved CPU reporting

## [1.8.1] - 2016-03-03
### Fixed
- Fixed bug with getting OS update

## [1.8.0] - 2016-03-02
### Changed
- Improved V480 Sensor report

## [1.7.9] - 2016-03-02
### Changed
- Improved V480 IO report

## [1.7.8] - 2016-03-02
### Changed
- Improved V490 Memory, CPU, and IO reports

## [1.7.7] - 2016-03-02
### Added
- Added initial support for V490

## [1.7.6] - 2016-03-02
### Fixed
- Fixed file extraction and added initial support for T5440

## [1.7.5] - 2016-02-22
### Changed
- Improved explorer extraction code to reduce IO

## [1.7.4] - 2016-02-22
### Changed
- Improved link information handling

## [1.7.3] - 2016-02-22
### Changed
- Improved hostname determination for dladm processing

## [1.7.2] - 2016-02-22
### Changed
- Improved handling and determination of gzip and tar

## [1.7.1] - 2016-02-21
### Added
- Added format usage information

## [1.7.0] - 2016-02-21
### Changed
- Cleaned up masking code

## [1.6.9] - 2016-02-21
### Added
- Added examples

## [1.6.8] - 2016-02-21
### Changed
- Cleaned up command line handling (moved to getopt long)

## [1.6.7] - 2016-02-20
### Fixed
- Fixed HTML output

## [1.6.6] - 2016-02-19
### Fixed
- More handling fixes for TZ

## [1.6.5] - 2016-02-19
### Added
- Added handling for null TZ

## [1.6.4] - 2016-02-18
### Fixed
- Fixed CPU reporting

## [1.6.3] - 2016-02-18
### Fixed
- Fixed module reporting

## [1.6.2] - 2016-02-18
### Changed
- Improved help for reporting options

## [1.6.1] - 2016-02-18
### Fixed
- Fixed file name date resolution

## [1.6.0] - 2016-02-18
### Added
- Added hostids to hardware determination

## [1.5.9] - 2016-02-18
### Fixed
- Fixed listing explorers to correctly show date with hyphenated host names

## [1.5.8] - 2016-02-18
### Fixed
- Fixed listing explorers to support hyphenated host names

## [1.5.7] - 2016-02-18
### Added
- Added tab delimited output that can be piped into something else

## [1.5.6] - 2016-02-17
### Fixed
- Fixed bug with output code

## [1.5.5] - 2016-02-16
### Added
- Added very basic HTML output

## [1.5.4] - 2016-02-16
### Added
- Added PCI scan reporting

## [1.5.3] - 2016-02-15
### Added
- Added Upgradeable slot reporting

## [1.5.2] - 2016-02-13
### Changed
- Improved physical network interface reporting for Solaris 11

## [1.5.1] - 2016-02-13
### Added
- Added support for OEM x86 machines

## [1.5.0] - 2016-02-13
### Fixed
- Fixed IPMI reporting

## [1.4.9] - 2016-02-13
### Added
- Added IPMI SEL reporting

## [1.4.8] - 2016-02-13
### Added
- Added IPMI MC reporting

## [1.4.7] - 2016-02-13
### Added
- Added IPMI Chassis reporting

## [1.4.6] - 2016-02-13
### Added
- Added IPMI FRU reporting

## [1.4.5] - 2016-02-13
### Changed
- Cleaned up ZFS reporting

## [1.4.4] - 2016-02-12
### Added
- Added component firmware reporting

## [1.4.3] - 2016-02-12
### Added
- Added domain support for M7

## [1.4.2] - 2016-02-12
### Added
- Added component serial information report

## [1.4.1] - 2016-02-12
### Added
- Initial Logical Domain information for M7

## [1.4.0] - 2016-02-12
### Fixed
- Fixed pigz detection and gzip handling

## [1.3.9] - 2016-02-12
### Added
- Added initial support for M7-8

## [1.3.8] - 2016-02-11
### Added
- Added basic install script for gems and made PDF related modules optional

## [1.3.7] - 2016-02-10
### Fixed
- Fixed bug with multiple QLogic firmware links

## [1.3.6] - 2016-02-10
### Changed
- Improved IO reporting for V440

## [1.3.5] - 2016-02-10
### Changed
- Improved X80R onboard FCAL reporting

## [1.3.4] - 2016-02-10
### Added
- Added PCI ID search

## [1.3.3] - 2016-02-10
### Changed
- Cleaned up memory reporting for a number of models

## [1.3.2] - 2016-01-27
### Changed
- Minor updates and cleanups

## [1.3.1] - 2016-01-27
### Fixed
- Fixes for memory output on M6 (needs to be re-written)

## [1.3.0] - 2016-01-27
### Added
- Added part descriptions

## [1.2.9] - 2016-01-27
### Added
- Added sensor information

## [1.2.8] - 2016-01-26
### Fixed
- Fixed bug with memory information on T5-X and T7-X

## [1.2.7] - 2016-01-26
### Changed
- Improved part description determination for HBAs with Oracle part numbers as names

## [1.2.6] - 2016-01-26
### Fixed
- Fixed bug with aggregate information

## [1.2.5] - 2016-01-26
### Fixed
- Fixed bug with link slot information

## [1.2.4] - 2016-01-26
### Added
- Added PAM support for Solaris 11

## [1.2.3] - 2016-01-26
### Fixed
- Fixed memory output for T5-X

## [1.2.2] - 2016-01-26
### Changed
- Slightly improved network interface reporting in IO report

## [1.2.1] - 2016-01-26
### Fixed
- Fixed VNIC information and added more part numbers

## [1.2.0] - 2016-01-21
### Added
- Added more part numbers

## [1.1.9] - 2016-01-21
### Added
- Added several new part numbers and updated LDoms release version to 3.3

## [1.1.8] - 2016-01-21
### Changed
- Cleaned up table code

## [1.1.7] - 2016-01-20
### Fixed
- Fixed memory reporting

## [1.1.6] - 2016-01-20
### Changed
- Improved model determination from hostid

## [1.1.5] - 2016-01-20
### Fixed
- Fixed OBP detection for some models

## [1.1.4] - 2016-01-20
### Added
- Added model look up table to provide models in list view

## [1.1.3] - 2016-01-20
### Added
- Added IP and MAC Address information to generic network output

## [1.1.2] - 2016-01-19
### Added
- Added support for inetadm

## [1.1.1] - 2016-01-19
### Added
- Added support for NTP

## [1.1.0] - 2016-01-19
### Changed
- Cleaned up usage information

## [1.0.9] - 2016-01-19
### Added
- Added support for PAM

## [1.0.8] - 2016-01-19
### Added
- Added support for syslog

## [1.0.7] - 2016-01-19
### Added
- Added processing for zone XML config files

## [1.0.6] - 2016-01-18
### Added
- Added configured zone information

## [1.0.5] - 2016-01-18
### Added
- Added aggregate info to network interface summary

## [1.0.4] - 2016-01-18
### Changed
- Improved hostname and IP determination

## [1.0.3] - 2016-01-18
### Changed
- Improved processing of inetd

## [1.0.2] - 2016-01-18
### Fixed
- Fixed determination of number of paths for disk

## [1.0.1] - 2016-01-18
### Added
- Added initial support for CDROMs to disk information

## [1.0.0] - 2016-01-18
### Changed
- Minor update to facter output

## [0.9.9] - 2016-01-15
### Added
- Added more service information

## [0.9.8] - 2016-01-15
### Added
- Added more network and ndd reporting

## [0.9.7] - 2016-01-14
### Fixed
- Fixed ZFS report

## [0.9.6] - 2016-01-14
### Added
- Added initial standalone Veritas report

## [0.9.5] - 2016-01-13
### Changed
- Improved disk size determination

## [0.9.4] - 2016-01-13
### Added
- Improved disk path determination and added disk IDs to disk report

## [0.9.3] - 2016-01-13
### Fixed
- Fixed bug with processing IO

## [0.9.2] - 2016-01-12
### Changed
- Improved reporting output

## [0.9.1] - 2016-01-12
### Fixed
- Fix for CUPS (don't print empty table)

## [0.9.0] - 2016-01-12
### Fixed
- Fix for empty disk paths

## [0.8.9] - 2015-09-10
### Changed
- Improved memory reporting for V440

## [0.8.8] - 2015-09-10
### Changed
- Improved memory reporting for 480R

## [0.8.7] - 2015-09-06
### Changed
- Improved disk information

## [0.8.6] - 2015-09-05
### Added
- Added additional ZFS reporting

## [0.8.5] - 2015-09-05
### Changed
- Improved usage information and reporting

## [0.8.4] - 2015-09-05
### Added
- Added additional link information

## [0.8.3] - 2015-09-05
### Added
- Added aggregate information

## [0.8.2] - 2015-09-05
### Added
- Added link information report

## [0.8.1] - 2015-09-05
### Added
- Added intial support for oce network device and vnic output

## [0.8.0] - 2015-09-05
### Changed
- Improved masking and output

## [0.7.9] - 2015-09-04
### Added
- Added support for LDom information on new M series

## [0.7.8] - 2015-09-04
### Added
- Added support for Domain information on new M series

## [0.7.7] - 2015-09-04
### Added
- Added Solaris 11 BE support

## [0.7.6] - 2015-09-04
### Changed
- Improved image scaling

## [0.7.5] - 2015-09-03
### Changed
- Improved masking support and tables for PDF output

## [0.7.4] - 2015-09-03
### Fixed
- Fixed issues with PDF creation

## [0.7.3] - 2015-09-03
### Fixed
- Fixed alignment for TOC

## [0.7.2] - 2015-09-01
### Added
- Added support for M[5,6,7]-32

## [0.7.1] - 2015-08-31
### Changed
- Improved code for putting images in PDF

## [0.7.0] - 2015-08-30
### Added
- Added check for parallel gzip

## [0.6.9] - 2015-08-30
### Changed
- Minor fix

## [0.6.8] - 2014-09-16
### Added
- Added code to reduce image size

## [0.6.7] - 2014-09-16
### Added
- Added mount information

## [0.6.6] - 2014-09-16
### Added
- Added swap information

## [0.6.5] - 2014-09-16
### Added
- Added diskinfo function

## [0.6.4] - 2014-09-16
### Added
- Added cups information

## [0.6.3] - 2014-09-16
### Added
- Added crypto information for Solaris 11

## [0.6.2] - 2014-09-16
### Added
- Added package properties and publisher information for Solaris 11

## [0.6.1] - 2014-09-16
### Added
- Added package mediator information for Solaris 11

## [0.6.0] - 2014-09-16
### Added
- Added package history for Solaris 11

## [0.5.9] - 2014-09-16
### Fixed
- Fixed package list for Solaris 11

## [0.5.8] - 2014-09-15
### Added
- Added support for M10-4S IO and CPU and cleaned up CPU output

## [0.5.7] - 2014-09-15
### Added
- Added dmidecode support

## [0.5.6] - 2014-09-14
### Added
- Added initial Ansible and Puppet Fact reporting support

## [0.5.5] - 2014-09-12
### Added
- Added support to download Handbook files

## [0.5.4] - 2014-09-12
### Changed
- Updated Handbook parsing code

## [0.5.3] - 2014-09-11
### Fixed
- Migrated most of masking code into output routine and fixed bugs with HBA handling

## [0.5.2] - 2014-09-11
### Added
- Added support for parsing Facter output

## [0.5.1] - 2014-09-10
### Changed
- More Handbook handling improvements

## [0.5.0] - 2014-09-10
### Changed
- Cleaned up Handbook output

## [0.4.9] - 2014-09-10
### Added
- Added Handbook processing and cleaned up Zone output

## [0.4.8] - 2014-09-08
### Changed
- Cleaned up PDF and CPU output

## [0.4.8] - 2014-09-08
### Added
- Initial PDF report support and various bug fixes

## [0.4.7] - 2014-09-07
### Changed
- Cleaned up text file output

## [0.4.6] - 2014-09-07
### Added
- Added initial support for multiple types of output

## [0.4.5] - 2014-09-04
### Changed
- Improved OBP version determination

## [0.4.4] - 2014-09-03
### Changed
- Improved firmware URL reporting

## [0.4.3] - 2014-09-03
### Changed
- Use pigz to speed up decompression if available

## [0.4.2] - 2014-09-03
### Fixed
- Fixed directory check

## [0.4.1] - 2014-07-07
### Changed
- Updated usage information

## [0.4.0] - 2014-07-05
### Changed
- Updated patch reporting

## [0.3.9] - 2014-07-05
### Added
- Added FRU support

## [0.3.8] - 2014-07-04
### Changed
- General code cleanup

## [0.3.7] - 2014-07-04
### Changed
- Cleaned up memory code

## [0.3.6] - 2014-07-04
### Fixed
- Fixed output for M3000

## [0.3.5] - 2014-07-04
### Fixed
- Fixed output for T5120

## [0.3.4] - 2014-07-04
### Added
- Added support for internal FC-AL on V series

## [0.3.3] - 2014-07-03
### Added
- Added V120 support

## [0.3.2] - 2014-07-03
### Added
- Added T2000 support and fixed bugs

## [0.3.1] - 2014-07-02
### Added
- Added masking for LDom configuration

## [0.3.0] - 2014-07-01
### Changed
- Improved LDom support

## [0.2.9] - 2014-07-01
### Added
- Added initial T series and LDom support

## [0.2.8] - 2014-06-30
### Fixed
- Fixed QLogic firmware reporting

## [0.2.7] - 2014-06-30
### Fixed
- Fixed available OBP determination

## [0.2.6] - 2014-06-29
### Fixed
- Fixed bug with -s option

## [0.2.5] - 2014-06-29
### Added
- Added support for determining XCP version on M10-4S

## [0.2.4] - 2014-06-28
### Added
- Added code to check methods, information, and firmware directory exist

## [0.2.3] - 2014-06-27
### Fixed
- Fixed version comparing code

## [0.2.2] - 2014-06-26
### Fixed
- Fixed tables for IO and CPU

## [0.2.1] - 2014-06-26
### Changed
- Split code out to make management easier

## [0.2.0] - 2014-06-26
### Fixed
- Fixed Fcode determination for QLogic HBAs

## [0.1.9] - 2014-06-26
### Changed
- Replaced versionomy module as it doesn't handle long version strings

## [0.1.8] - 2014-06-26
### Fixed
- Fixed option handling

## [0.1.7] - 2014-06-23
### Fixed
- Fixed bugs with OBP version reporting

## [0.1.6] - 2014-06-23
### Added
- Added code to extract symlinks from explorer

## [0.1.5] - 2014-06-22
### Added
- Added OBP function

## [0.1.4] - 2014-06-22
### Added
- Added explorer listing and cleaned up code

## [0.1.3] - 2013-11-10
### Changed
- Code clean up

## [0.1.2] - 2013-11-09
### Added
- Added code to mask identifiable data

## [0.1.1] - 2013-11-08
### Added
- Added patch information

## [0.1.0] - 2013-11-08
### Added
- Added package information

## [0.0.9] - 2013-11-08
### Added
- Added kernel module support

## [0.0.8] - 2013-11-08
### Changed
- Cleaned up output routine

## [0.0.7] - 2013-11-08
### Added
- Added Live Upgrade support

## [0.0.6] - 2013-11-07
### Added
- Added inetd service check

## [0.0.5] - 2013-11-06
### Added
- Added initial security check code

## [0.0.4] - 2013-10-28
### Added
- Added code to check array of files in tar archive before extracting to speed up code

## [0.0.3] - 2013-10-26
### Changed
- Split reporting into separate reports

## [0.0.2] - 2013-10-26
### Added
- Added uptime, timezone, install cluster and eeprom information

## [0.0.1] - 2013-10-26
### Added
- Initial working version

## Webserver (`webserver.rb`)

## [0.2.3] - 2026-09-29
### Fixed
- Fixed startup crash (`uninitialized constant Rack::Handler`) against current `sinatra`/`rack` (Rack 3 moved server handlers, including WEBrick, into the separate `rackup` gem as `Rackup::Handler`); the custom SSL `run!` override now uses `Rackup::Handler::WEBrick`
- Added `webrick` and `rackup` to `requirements.txt` (`webrick` stopped being a default Ruby gem as of Ruby 3.0; `rackup` provides the Rack 3 server handlers Sinatra now depends on)

## [0.2.2] - 2026-09-29
### Fixed
- Fixed `ssl_certificate`/`ssl_key` paths, which were still hardcoded as `ssl/cert.crt` and `ssl/pkey.pem` (resolved against the current working directory) after `$ssl_dir` was made script-relative; the server would look for (and regenerate) the TLS cert/key in the wrong place when started from any directory other than its own
### Changed
- Removed duplicate script-directory detection in `methods/common.rb`; it now reuses the `$script_dir` global already set by `parsec.rb`/`webserver.rb` instead of recomputing it independently

## [0.2.1] - 2026-09-29
### Fixed
- Fixed script directory detection in `methods/common.rb` (was `File.basename($0)`, should have been `File.dirname($0)`), which forced parsec.rb/webserver.rb to only work when invoked with the current directory equal to the repo root
- Fixed loading of `methods/*.rb` to resolve relative to the script's own directory instead of the current working directory

## [0.2.0] - 2026-09-29
### Changed
- Updated license to CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike) from CC-BA (Attribution only)

## [0.1.8] - 2016-12-27
### Fixed
- Fixed bug and added code to get front-end IP and set it to bind IP

## [0.1.7] - 2016-11-03
### Added
- Added ability to search by customer and some other fields to explorer list view

## [0.1.6] - 2016-08-13
### Fixed
- Fix issue with configs not loading after inital load

## [0.1.5] - 2016-08-11
### Fixed
- Fixed bug with photos code and some model header determination

## [0.1.4] - 2016-08-11
### Added
- Added photos

## [0.1.3] - 2016-08-10
### Added
- Added basic upload capability

## [0.1.2] - 2016-08-10
### Changed
- Moved basic crypt htpasswd support to bcrypt

## [0.1.1] - 2016-08-09
### Added
- Added basic htpasswd support

## [0.1.0] - 2016-08-09
### Added
- Added SSL support for webserver

## [0.0.9] - 2016-08-07
### Fixed
- Bug fixes

## [0.0.8] - 2016-08-07
### Added
- Added ability to set bind and sessions

## [0.0.7] - 2016-08-07
### Changed
- Redirected error page to help page

## [0.0.6] - 2016-08-07
### Changed
- Layout improvements

## [0.0.5] - 2016-08-06
### Fixed
- More HTML output fixes

## [0.0.4] - 2016-08-06
### Added
- Initial webserver help information

## [0.0.3] - 2016-08-06
### Added
- Added help and stopped processing views inline

## [0.0.2] - 2016-08-05
### Changed
- Created seperate changelogs

## [0.0.1] - 2016-08-05
### Added
- Initial working webserver
