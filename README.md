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

- [Memory](https://github.com/lateralblast/parsec/wiki/4.1-Memory)
- [IO](https://github.com/lateralblast/parsec/wiki/4.2-IO)
- [Host](https://github.com/lateralblast/parsec/wiki/4.3-Host)
- [CPU](https://github.com/lateralblast/parsec/wiki/4.4-CPU)
- [LDOMs](https://github.com/lateralblast/parsec/wiki/4.5-LDoms)

Requirements
------------

Ruby Gems:

- rubygems
- fileutils
- getopt/std
- pathname
- hex_string
- terminal-table

A base set of firmware information is provided.
This information is created using [oort](https://github.com/lateralblast/oort).
In order to keep this information up to date, a MOS (My Oracle Support) account is required.

In order to work, parsec requires three directories:

- methods
  - where the parsec modules are located
  - cloning parsec from git will get these
- information
  - where firmware and other information is location
  - parsec comes with some base information which can be updated using the firith script
  - see the [Getting started with Parsec](https://github.com/lateralblast/parsec/wiki/3.-Getting-Started) wiki
- firmware (under development)
  - the actual firmware
  - required for some machines to obtain further information
  - can be the repository generated from the firith script
  - see the [Getting started with Parsec](https://github.com/lateralblast/parsec/wiki/3.-Getting-Started) wiki


