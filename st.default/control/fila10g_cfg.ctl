* sample fila10g_cfg.ctl file
*
* lines that start with asterisks '*' are comments and may appear anywhere
* no blank lines or leading white space allowed
* sections are delimited by lines that start with $, or $sections
*
* currently only one $section, commented out, is defined:
*  $config name
*
* where 'name' is the configuration name, maximum 16 characters (no spaces) 
* maximum 21 configurations
*
* all non-comment lines until the next '$config name' line are used for
* this configuration and contain raw fila10g commands (i.e. no leading
* 'fila10g=' should be included). maximum command length is 128 characters,
* including any internal spaces, trailing spaces are trimmed
*
* the configuration to be used can be selected in FMSET when 's'yncing
* the fila10g
*
*$config first
*general setup
*arp off
*vdif_enc on
*
*customize IPs, ports, gateways, MACs, NMs, and destinations,
*for your station, configure appropriate ethXs
*
*The fila10g does not automatically map IPv4 addresses to ethernet
* MAC addresses (the ARP table).See "arp off" above, although that has
* other (positive) consequences as well.
*The ARP table must be programmed manually using 'tengbarp' below.
*Parameters are the last number from the destination's dotted-quad
* IPv4 address ('11' here, from '192.168.2.11')
*and ??:??:??:??:??:?? is the MAC address of the FlexBuff interface
* with this IPv4 address.
*
*The destinaton port must agree with the FlexBuff, which uses 2630 by default.
* If you change this you will need to program the Flexbuff with
* "mk5=net_port = y;" where "y" is the port you used. You could put
* that command in "initi" and "sched_initi" to try to make it reliable
* but it would better to just not change the port.
*
*eth0 follows
*tengbcfg eth0 ip=192.168.2.11 gateway=192.168.2.1
*tengbcfg eth0 mac=xx:xx:xx:xx:xx:xx
*tengbcfg eth0 nm=27
*destination 0 192.168.2.21:2630
*tengbarp eth0 21 ??:??:??:??:??:??
*
*eth1 follows
*tengbcfg eth1 ip=192.168.3.11 gateway=192.168.3.1
*tengbcfg eth1 mac=yy:yy:yy:yy:yy:yy
*tengbcfg eth1 nm=27
*destination 1 192.168.3.21:2630
*tengbarp eth1 21 ??:??:??:??:??:??
