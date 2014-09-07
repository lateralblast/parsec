![alt tag](https://raw.githubusercontent.com/lateralblast/parsec/master/sparc_t5.png)

PARSEC
======

Parse, Analyse, and Report on Solaris Explorer Configuration/Content

Introduction
------------

A ruby script to parse a Sun Oracle Solaris explorer file and extract information.
There is some reporting capability being built into the script.

Some of the features include:

- Map IO paths and disk
- Determine part numbers where possible
- Report on firmware versions
  - Report if newer version is available
- Security checks for defaults and kernel parameters
- Mask customer information, WWNs, etc

The reporting options include:

- Open Boot Prom information
- Host information
- EEPROM information
- Operating Sytem information
- Coreadm information
- Dupadm information
- Explorer information
- CPU information
- Memory information
- IO Information (Controllers, HBAs etc)
- Disk information
- Kernel information
- Zone information
- All security information
- Password information
- System information
- Login information
- Sendmail information
- Inetinit information
- Su information
- Inetd information
- Cron information
- keyserv information
- Telnet information
- Power information
- Suspend information
- SSH information
- Filesystem information
- Services information
- LiveUpgrade information
- Locale information
- Module information
- Package information
- Patch information
- TCP information
- UDP information
- LDom information
- FRU information

License
-------

This software is licensed as CC-BA (Creative Commons By Attrbution)

http://creativecommons.org/licenses/by/4.0/legalcode


Documentation
-------------

- [Wiki](https://github.com/lateralblast/parsec/wiki)
- [Features](https://github.com/lateralblast/parsec/wiki/1.-Features)
- [Usage](https://github.com/lateralblast/parsec/wiki/2.-Usage)
- [Requirements](https://github.com/lateralblast/parsec/wiki/6.-Requirements)

Getting Started
---------------

- [Getting started with Parsec](https://github.com/lateralblast/parsec/wiki/3.-Getting-Started)

Examples
--------

Hardware Examples:

- [Memory](https://github.com/lateralblast/parsec/wiki/4.1.1.-Memory)
- [IO](https://github.com/lateralblast/parsec/wiki/4.1.2.-IO)
- [Power](https://github.com/lateralblast/parsec/wiki/4.1.3.-Power)
- [Suspend](https://github.com/lateralblast/parsec/wiki/4.1.4.-Suspend)
- [ILOM](https://github.com/lateralblast/parsec/wiki/4.1.5.-ILOM)
- [Disks](https://github.com/lateralblast/parsec/wiki/4.1.6.-Disks)
- [OBP](https://github.com/lateralblast/parsec/wiki/4.1.7.-OBP)
- [FRU](https://github.com/lateralblast/parsec/wiki/4.1.8.-FRU)
- [CPU](https://github.com/lateralblast/parsec/wiki/4.1.9.-CPU)

Software Examples:

- [Explorer](https://github.com/lateralblast/parsec/wiki/4.2.1.-Explorer)
- [Coreadm](https://github.com/lateralblast/parsec/wiki/4.2.2.-Coreadm)
- [Dumpadm](https://github.com/lateralblast/parsec/wiki/4.2.3.-Dumpadm)
- [Packages](https://github.com/lateralblast/parsec/wiki/4.2.4.-Packages)
- [Patches](https://github.com/lateralblast/parsec/wiki/4.2.5.-Patches)

Network Examples:

- [TCP](https://github.com/lateralblast/parsec/wiki/4.3.1.-TCP)
- [UDP](https://github.com/lateralblast/parsec/wiki/4.3.2.-UDP)
- [SSH](https://github.com/lateralblast/parsec/wiki/4.3.3.-SSH)
- [Sendmail](https://github.com/lateralblast/parsec/wiki/4.3.4.-Sendmail)
- [Telnet](https://github.com/lateralblast/parsec/wiki/4.3.5.-Telnet)

Operating System Examples:

- [Kernel](https://github.com/lateralblast/parsec/wiki/4.4.1.-Kernel)
- [Modules](https://github.com/lateralblast/parsec/wiki/4.4.2.-Modules)
- [Locale](https://github.com/lateralblast/parsec/wiki/4.4.3.-Locale)
- [Filesystem](https://github.com/lateralblast/parsec/wiki/4.4.4.-Filesystem)
- [LiveUpgrade](https://github.com/lateralblast/parsec/wiki/4.4.5.-LiveUpgrade)
- [Services](https://github.com/lateralblast/parsec/wiki/4.4.6.-Services)
- [Host](https://github.com/lateralblast/parsec/wiki/4.4.7.-Host)
- [EEPROM](https://github.com/lateralblast/parsec/wiki/4.4.8.-EEPROM)

Virtualisation Examples:

- [LDoms](https://github.com/lateralblast/parsec/wiki/4.5.1.-LDoms)
- [Zones](https://github.com/lateralblast/parsec/wiki/4.5.2.-Zones)

Security Information:

- [System](https://github.com/lateralblast/parsec/wiki/4.6.1.-System)
- [Password](https://github.com/lateralblast/parsec/wiki/4.6.2.-Password)
- [Login](https://github.com/lateralblast/parsec/wiki/4.6.3.Login)
- [Inetd](https://github.com/lateralblast/parsec/wiki/4.6.4.-Inetd)
- [Inetinit](https://github.com/lateralblast/parsec/wiki/4.6.5.-Inetinit)
- [Su](https://github.com/lateralblast/parsec/wiki/4.6.6.-Su)
- [Cron](https://github.com/lateralblast/parsec/wiki/4.6.7.-Cron)
- [Keyserv](https://github.com/lateralblast/parsec/wiki/4.6.8.-Keyserv)

Requirements
------------

Tools:

- Uses pigz if available

Ruby Gems:

- rubygems
- fileutils
- getopt/std
- pathname
- hex_string
- terminal-table
- prawn
- prawn/table
- pathname
- etc
- fastimage
- unpack
- enumerator

A base set of firmware information is provided.
This information is created using [oort](https://github.com/lateralblast/oort).
In order to keep this information up to date, a MOS (My Oracle Support) account is required.

In order to work, parsec requires three directories:

- methods
  - where the parsec modules are located
  - cloning parsec from git will get these
- information
  - where firmware and other information is location
  - parsec comes with some base information which can be updated using the [oort](https://github.com/lateralblast/oort) script
  - see the [Getting started with Parsec](https://github.com/lateralblast/parsec/wiki/3.-Getting-Started) wiki
- firmware (under development)
  - the actual firmware
  - required for some machines to obtain further information
  - can be the repository generated from the [oort](https://github.com/lateralblast/oort) script
  - see the [Getting started with Parsec](https://github.com/lateralblast/parsec/wiki/3.-Getting-Started) wiki


