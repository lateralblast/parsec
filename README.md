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

Examples
--------

Show memory information:

```
$ parsec.rb -s hostname -R host

+--------------+----------+
|   Memory Information    |
+--------------+----------+
| Item         | Value    |
+--------------+----------+
| System Board | 00       |
| Group(s)     | A        |
| Size         | 32768MB  |
| Status       | okay     |
| DIMMs        | 4        |
| DIMM Size    | 8192MB   |
| Mirror       | no       |
| Interleave   | 2-way    |
| System Board | 00       |
| Group(s)     | B        |
| Size         | 32768MB  |
| Status       | okay     |
| DIMMs        | 4        |
| DIMM Size    | 8192MB   |
| Mirror       | no       |
| Interleave   | 2-way    |
+--------------+----------+
```

Show IO information:

```
$ parsec.rb -s hostname -R io -m

+--------------------+------------------------------------------------------------------------------+
|                                          IO Information                                           |
+--------------------+------------------------------------------------------------------------------+
| Item               | Value                                                                        |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIe                                                                         |
| Name               | N/A                                                                          |
| Path               | /pci@0,600000/pci@0                                                          |
| Slot               | 1                                                                            |
| Driver             | pxb_plx                                                                      |
| Instance           | 0                                                                            |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIe                                                                         |
| Name               | N/A                                                                          |
| Path               | /pci@0,600000/pci@0/pci@0                                                    |
| Slot               | 1                                                                            |
| Driver             | pxb_plx                                                                      |
| Instance           | 1                                                                            |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIe                                                                         |
| Name               | N/A                                                                          |
| Path               | /pci@0,600000/pci@0/pci@1                                                    |
| Slot               | 1                                                                            |
| Driver             | pxb_plx                                                                      |
| Instance           | 2                                                                            |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIe                                                                         |
| Name               | N/A                                                                          |
| Path               | /pci@0,600000/pci@0/pci@2                                                    |
| Slot               | 1                                                                            |
| Driver             | pxb_plx                                                                      |
| Instance           | 3                                                                            |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIe                                                                         |
| Name               | N/A                                                                          |
| Path               | /pci@0,600000/pci@0/pci@8                                                    |
| Slot               | 1                                                                            |
| Driver             | pxb_plx                                                                      |
| Instance           | 4                                                                            |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIe                                                                         |
| Name               | LSI,1068E                                                                    |
| Path               | /pci@0,600000/pci@0/pci@0/scsi@0                                             |
| Slot               | 1                                                                            |
| Controller         | c0                                                                           |
| Driver             | mpt                                                                          |
| Instance           | 0                                                                            |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIx                                                                         |
| Name               | N/A                                                                          |
| Path               | /pci@0,600000/pci@0/pci@1/pci@0                                              |
| Slot               | 0                                                                            |
| Driver             | pxb_bcm                                                                      |
| Instance           | 0                                                                            |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIx                                                                         |
| Name               | N/A                                                                          |
| Path               | /pci@0,600000/pci@0/pci@1/pci@0/network@4                                    |
| Slot               | 0                                                                            |
| Driver             | bge                                                                          |
| Instance           | 0                                                                            |
| Port               | 4                                                                            |
| Interface          | xxxxxxxx                                                                     |
| Hostname           | xxxxxxxx                                                                     |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIx                                                                         |
| Name               | N/A                                                                          |
| Path               | /pci@0,600000/pci@0/pci@1/pci@0/network@4,1                                  |
| Slot               | 0                                                                            |
| Driver             | bge                                                                          |
| Instance           | 1                                                                            |
| Port               | 1                                                                            |
| Interface          | xxxxxxxx                                                                     |
| Hostname           | xxxxxxxx                                                                     |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIx                                                                         |
| Name               | N/A                                                                          |
| Path               | /pci@0,600000/pci@0/pci@2/pci@0                                              |
| Slot               | 0                                                                            |
| Driver             | pxb_bcm                                                                      |
| Instance           | 1                                                                            |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIx                                                                         |
| Name               | N/A                                                                          |
| Path               | /pci@0,600000/pci@0/pci@2/pci@0/network@4                                    |
| Slot               | 0                                                                            |
| Driver             | bge                                                                          |
| Instance           | 2                                                                            |
| Port               | 4                                                                            |
| Interface          | xxxxxxxx                                                                     |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIx                                                                         |
| Name               | N/A                                                                          |
| Path               | /pci@0,600000/pci@0/pci@2/pci@0/network@4,1                                  |
| Slot               | 0                                                                            |
| Driver             | bge                                                                          |
| Instance           | 3                                                                            |
| Port               | 1                                                                            |
| Interface          | xxxxxxxx                                                                     |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIe                                                                         |
| Name               | SUNW,pcie-qgc                                                                |
| Path               | /pci@0,600000/pci@0/pci@8/network@0                                          |
| Slot               | 1                                                                            |
| Driver             | nxge                                                                         |
| Instance           | 0                                                                            |
| Port               | 0                                                                            |
| Interface          | xxxxxxxx                                                                     |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIe                                                                         |
| Name               | SUNW,pcie-qgc                                                                |
| Path               | /pci@0,600000/pci@0/pci@8/network@0,1                                        |
| Slot               | 1                                                                            |
| Driver             | nxge                                                                         |
| Instance           | 1                                                                            |
| Port               | 1                                                                            |
| Interface          | xxxxxxxx                                                                     |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIe                                                                         |
| Name               | SUNW,pcie-qgc                                                                |
| Path               | /pci@0,600000/pci@0/pci@8/network@0,2                                        |
| Slot               | 1                                                                            |
| Driver             | nxge                                                                         |
| Instance           | 2                                                                            |
| Port               | 2                                                                            |
| Interface          | xxxxxxxx                                                                     |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIe                                                                         |
| Name               | SUNW,pcie-qgc                                                                |
| Path               | /pci@0,600000/pci@0/pci@8/network@0,3                                        |
| Slot               | 1                                                                            |
| Driver             | nxge                                                                         |
| Instance           | 3                                                                            |
| Port               | 3                                                                            |
| Interface          | xxxxxxxx                                                                     |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIe                                                                         |
| Name               | N/A                                                                          |
| Path               | /pci@1,700000/pci@0                                                          |
| Slot               | 2                                                                            |
| Driver             | pxb_plx                                                                      |
| Instance           | 5                                                                            |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIe                                                                         |
| Name               | N/A                                                                          |
| Path               | /pci@1,700000/pci@0/pci@0                                                    |
| Slot               | 2                                                                            |
| Driver             | pxb_plx                                                                      |
| Instance           | 6                                                                            |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIe                                                                         |
| Name               | N/A                                                                          |
| Path               | /pci@1,700000/pci@0/pci@8                                                    |
| Slot               | 2                                                                            |
| Driver             | pxb_plx                                                                      |
| Instance           | 7                                                                            |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIe                                                                         |
| Name               | N/A                                                                          |
| Path               | /pci@1,700000/pci@0/pci@9                                                    |
| Slot               | 2                                                                            |
| Driver             | pxb_plx                                                                      |
| Instance           | 8                                                                            |
| IOU                | 00                                                                           |
| Type               | PCIe                                                                         |
| Name               | LPe11000-S                                                                   |
| Path               | /pci@1,700000/pci@0/pci@0/SUNW,emlxs@0                                       |
| Slot               | 2                                                                            |
| Controller         | c1                                                                           |
| Driver             | fp                                                                           |
| Instance           | 0                                                                            |
| Serial             | XXXXXXXX                                                                     |
| Node WWN           | XXXXXXXX                                                                     |
| State              | online                                                                       |
| Type               | N-port                                                                       |
| BCode              | 5.02a1                                                                       |
| Current Speed      | 4Gb                                                                          |
| Supported Speeds   | 1Gb 2Gb 4Gb                                                                  |
| Firmware Version   | 2.82a4 (Z3D2.82A4)                                                           |
| Driver Name        | emlxs                                                                        |
| Driver Version     | 2.61i (2011.08.10.11.40)                                                     |
| Link Failures      | 0                                                                            |
| Sync Losses        | 1                                                                            |
| Signal Losses      | 0                                                                            |
| Protocol Errors    | 0                                                                            |
| Invalid Tx Words   | 0                                                                            |
| Invalid CRC        | 0                                                                            |
| FCode              | 1.50a9                                                                       |
| Part Number        | SG-XPCIE1FC-EM4                                                              |
| Installed Firmware | 2.82a4 (Z3D2.82A4)                                                           |
| Available Firmware | 3.10a6 (Newer)                                                               |
| Firmware Download  | http://www-dl.emulex.com/support/elx/rt960/b12/firmware/LPe11000/zo310a6.zip |
| Part Description   | 4Gigabit/Sec PCI-E Single FC Host Adapter                                    |
+--------------------+------------------------------------------------------------------------------+
| IOU                | 00                                                                           |
| Type               | PCIe                                                                         |
| Name               | LPe11000-S                                                                   |
| Path               | /pci@1,700000/pci@0/pci@9/SUNW,emlxs@0                                       |
| Slot               | 2                                                                            |
| Controller         | c2                                                                           |
| Driver             | fp                                                                           |
| Instance           | 1                                                                            |
| Serial             | XXXXXXXX                                                                     |
| Node WWN           | XXXXXXXX                                                                     |
| State              | online                                                                       |
| Type               | N-port                                                                       |
| BCode              | 5.02a1                                                                       |
| Current Speed      | 4Gb                                                                          |
| Supported Speeds   | 1Gb 2Gb 4Gb                                                                  |
| Firmware Version   | 2.82a4 (Z3D2.82A4)                                                           |
| Driver Name        | emlxs                                                                        |
| Driver Version     | 2.61i (2011.08.10.11.40)                                                     |
| Link Failures      | 0                                                                            |
| Sync Losses        | 1                                                                            |
| Signal Losses      | 0                                                                            |
| Protocol Errors    | 0                                                                            |
| Invalid Tx Words   | 0                                                                            |
| Invalid CRC        | 0                                                                            |
| FCode              | 1.50a9                                                                       |
| Part Number        | SG-XPCIE1FC-EM4                                                              |
| Installed Firmware | 2.82a4 (Z3D2.82A4)                                                           |
| Available Firmware | 3.10a6 (Newer)                                                               |
| Firmware Download  | http://www-dl.emulex.com/support/elx/rt960/b12/firmware/LPe11000/zo310a6.zip |
| Part Description   | 4Gigabit/Sec PCI-E Single FC Host Adapter                                    |
+--------------------+------------------------------------------------------------------------------+
```

Show Host information:

```
$ parsec.rb -s hostname -R host -m

+------------------+------------------------------+
|                Host Information                 |
+------------------+------------------------------+
| Item             | Value                        |
+------------------+------------------------------+
| Hostname         | explorer-host                |
| Timezone         | Country/State                |
| HostID           | XXXXXXXX                     |
| Serial           | XXXXXXXX                     |
| OS Name          | SunOS                        |
| Domain           | domain                       |
| Name Server(s)   | nameserver                   |
| Search Domain(s) | search                       |
| Kernel Version   | Generic_147440-27            |
| Architecture     | sun4u                        |
| OS Version       | 5.10                         |
| OS Update        | 7                            |
| OS Release       | 5/09                         |
| OS Build         | s10s_u7wos_08                |
| Boot Time        | Sun 10 Nov 2013 10:41:47 EST |
| System Uptime    | 1 day(s)                     |
| Install Cluster  | SUNWCXall                    |
+------------------+------------------------------+

+------------------------------+----------------------------------+
|                      Coreadm Configuration                      |
+------------------------------+----------------------------------+
| Item                         | Value                            |
+------------------------------+----------------------------------+
| global core file pattern     | /var/core/core_%n_%f_%u_%g_%t_%p |
| global core file content     | default                          |
| init core file pattern       | /var/core/core_%n_%f_%u_%g_%t_%p |
| init core file content       | default                          |
| global core dumps            | enabled                          |
| per-process core dumps       | disabled                         |
| global setid core dumps      | enabled                          |
| per-process setid core dumps | disabled                         |
| global core dump logging     | enabled                          |
+------------------------------+----------------------------------+

+------------------+--------------------------------------+
|                  Dumpadm Configuration                  |
+------------------+--------------------------------------+
| Item             | Value                                |
+------------------+--------------------------------------+
| Dump content     | kernel pages                         |
| Dump device      | /dev/zvol/dsk/rpool/dump (dedicated) |
| Savecore enabled | yes                                  |
| Save compressed  | on                                   |
+------------------+--------------------------------------+

+-------------+---------------------------------------+
|                Explorer Information                 |
+-------------+---------------------------------------+
| Item        | Value                                 |
+-------------+---------------------------------------+
| Customer    | Company X                             |
| Contract ID |                                       |
| User        | Customer X                            |
| Email       | customre@company.com                  |
| Phone       | XXX-XXXX-XXXX                         |
| Country     | Country                               |
| Directory   | /Users/spindler/Code/parsec/explorers |
| File        | explorer.tar.gz                       |
| STB Version | 7.2                                   |
| Date        | 20/05/2013                            |
| Time        | 07:03                                 |
+-------------+---------------------------------------+

+-----------------------+------------------------------------------------------+
|                              System Information                              |
+-----------------------+------------------------------------------------------+
| Item                  | Value                                                |
+-----------------------+------------------------------------------------------+
| Model                 | Oracle Corporation Sun SPARC Enterprise M3000 Server |
| OBP Version           | OBP 4.24.13 2010/02/08 13:17                         |
| Available OBP Version | OBP 4.33.5.d (Newer)                                 |
| Memory                | 65536 Megabytes                                      |
+-----------------------+------------------------------------------------------+
```

Show CPU information:

```
$ parsec.rb -s hostname -R cpu

+--------------+-----------------+
|        CPU Information         |
+--------------+-----------------+
| Item         | Value           |
+--------------+-----------------+
| System Board | 00              |
| Socket       | 0               |
| Mask         | 161             |
| Speed        | 2750 MHz        |
| Cache        | 5.0             |
| IDs          | 0,1,2,3,4,5,6,7 |
| Type         | SPARC64-VII     |
+--------------+-----------------+
```
