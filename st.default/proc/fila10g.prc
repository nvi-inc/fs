define  fila10g_cfg     00000000000x
"general setup
fila10g=arp off
fila10g=vdif_enc on
"
"customize IPs, ports, gateways, MACs, NMs, and destinations,
"for your station, configure appropriate ethXs
"
"The fila10g does not automatically map IPv4 addresses to ethernet
" MAC addresses (the ARP table).See "arp off" above, although that has
" other (positive) consequences as well.
"The ARP table must be programmed manually using 'tengbarp' below.
"Parameters are the last number from the destination's dotted-quad
" IPv4 address ('11' here, from '192.168.2.11')
"and xx:xx:xx:xx:xx:xx is the MAC address of the FlexBuff interface
" with this IPv4 address.
"
"The destinaton port must agree with the FlexBuff, which uses 2630 by default.
" If you change this you will need to program the Flexbuff with
" "mk5=net_port = y;" where "y" is the port you used. You could put
" that command in "initi" and "sched_initi" to try to make it reliable
" but it would better to just not change the port.
"
"eth0 follows
fila10g=tengbcfg eth0 ip=192.168.2.21 gateway=192.168.2.1
fila10g=tengbcfg eth0 mac=00:60:dd:45:66:69
fila10g=tengbcfg eth0 nm=27
fila10g=destination 0 192.168.2.11:2630
fila10g=tengbarp eth0 11 xx:xx:xx:xx:xx:xx
"
"eth1 follows
fila10g=tengbcfg eth1 ip=192.168.3.21 gateway=192.168.3.1
fila10g=tengbcfg eth1 mac=00:60:dd:45:66:79
fila10g=tengbcfg eth1 nm=27
fila10g=destination 1 192.168.3.11:2630
fila10g=tengbarp eth1 11 xx:xx:xx:xx:xx:xx
enddef
