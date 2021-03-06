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
- Output in the following formats:
  - Plain console text which can be piped into other applications
  - Text table console output
  - HTML output
  - Wiki output
- A Sinatra based webserver to serve up configs

Usage
-----

The default output has changed to pipe (white space delimited plain text).

To get the old style terminal tables, use the table output format type, e.g.:

```
$ ./parsec.rb --server=hostname --report=all --format=table
```

To get the html formated output use the html output format type, e.g.:

```
$ ./parsec.rb --server=hostname --report=all --format=html
```

To get pdf output, use the pdf format output type, e.g.:

```
$ ./parsec.rb --server=hostname --report=all --format=pdf
```

To run the Sinatra based webserver:

```
$ ./webserver
```

This will start up a webserver on port 9494

![alt tag](https://raw.githubusercontent.com/lateralblast/parsec/master/webserver_example.png)

Authentication can be enable by setting the enable_auth flag in webserver.rb:

```
enable_auth = true
```

Certificates and keys are stored in the ssl directory:

```
$ ls -l ssl
total 16
-rw-r--r--  1 spindler  staff  1383  9 Aug 23:27 cert.crt
-rw-r--r--  1 spindler  staff   891  9 Aug 23:27 pkey.pem
```

If they don't exist the script will try to create them on startup.

Otherwise use the openssl command:

```
$ cd ssl
$ openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout pkey.pem -out cert.crt
```

The server looks for users in a .htpasswd file in the views directory, eg:

```
$ cat ./views/.htpasswd 
spindler:$2y$05$0Ntm14Sl3Ix.qUSd537V8eUuhM6nJiqSM9mB18Pp5bnbg0ZhtxQAq
```

The password algorithm is bcrypt.

Password entries can be created using htpasswd, eg:

```
$ htpasswd -n -b -B spindler test >> ./views/.htpasswd 
```

If you want photos to be displayed, you'll need the <a href="https://github.com/lateralblast/ssp">Sun System Pictures</a> archive.

To enable photos, clone the archive to a location of your choice and symlink it to the photos directory in the root directory of parsec, e.g.:

```
$ cd /export
$ git clone https://github.com/lateralblast/ssp.git
$ cd /export/parsec
$ ln -s /export/ssp/images ./photos
```

Reports
-------

The reporting options include:

- Report on Aggregate information
- Report on Everything
- Report on Coreadm information
- Report on CPU information
- Report on Cron information
- Report on Crypto information
- Report on CUPS information
- Report on Disks
- Report on Disk / Filesystem Usage
- Report on Dumpadm information
- Report on EEPROM
- Report on Elfsign information
- Report on Explore information
- Report on Firmware information
- Report on FRU information
- Report on Filesystem information
- Report on Firmware information
- Report on FRU information
- Report on Host information
- Report on inetadm information
- Report on inetd information
- Report on inetinit information
- Report on IPMI information
- Report on IO information
- Report on LDom information
- Report on Link information
- Report on Locale information
- Report on Live Upgrade information
- Report on Kernel information
- Report on Keyserv information
- Report on Memory information
- Report on Kernel Module information
- Report on Mount information
- Report on ndd information
- Report on Network information
- Report on NTP information
- Report on OBP information
- Report on OS information
- Report on package information
- Report on PAM information
- Report on Password information
- Report on Patch information
- Report on PCI information
- Report on Power information
- Report on Security information
- Report on Sendmail settings
- Report on Sensor information
- Report on Chassis Serial information
- Report on Component Serial information
- Report on Services information
- Report on SNMP information
- Report on SPEC information
- Report on SSH information
- Report on SU information
- Report on Suspend information
- Report on Syslog information
- Report on System information
- Report on Swap information
- Report on TCP information
- Report on Telnet information
- Report on Upgradeable slot information
- Report on UDP information
- Report on VNIC information
- Report on Veritas information
- Report on ZFS information
- Report on Zone information

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

General Examples:

- [General Information](4.0.-General-Information)

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
- S tar required for Operating Systems other than Solaris
- ImageMagick required for image processing for PDF reports
- libiconv

Required Ruby Gems (required for text reports):

- rubygems
- fileutils
- getopt/std
- pathname
- hex_string
- terminal-table
- pathname
- etc
- unpack
- enumerator
- iconv

Optional Ruby Gems (required for PDF reports)

- prawn
- prawn/table
- fastimage
- nokogiri
- rmagick

Aditional gems required for webserver:

- erb
- sinatra

There is a very basic script to install gems

```
./utils/generic/install_gems.sh
```

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
