PARSEC
======

Parse, Analyse, and Report on Solaris Explorer Configuration

Introduction
------------

A ruby script to parse a Sun Oracle Solaris explorer file and extract information.
There is some reporting capability being built into the script.

Some of the features included:

- Map IO paths and disk
- Determine part numbers where possible
- Report on firmware versions
- Security checks for defaults and kernel parameters
- Mask customer information, WWNs, etc

License
-------

This software is licensed as CC-BA (Creative Commons By Attrbution)

http://creativecommons.org/licenses/by/4.0/legalcode

Usage
-----

```
$ parsec -[abcdehmvACDEHIKMOSVZf:s:w:R:o:]

-h: Print help
-f: Specify Explorer file to process
-s: Specify System to process
    (Filename will be determined if it exists)
-A: Print all configuration information (default)
-E: Print EEPROM configuration information
-I: Print IO configuration information
-H: Print Host information
-C: Print CPU configuration information
-R: Print configuration information for a specific component
-m: Mask data (hostnames etc)
```

Wiki
----

https://github.com/richardatlateralblast/parsec/wiki

Examples
--------

- [https://github.com/richardatlateralblast/parsec/3.1-Memory](3.1-Memory)
- [https://github.com/richardatlateralblast/parsec/3.2-IO](3.2-IO)
- [https://github.com/richardatlateralblast/parsec/3.3-Host](3.3-Host)
- [https://github.com/richardatlateralblast/parsec/3.4-CPU](3.4-CPU)






