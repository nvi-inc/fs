*rdbcc.ctl example file
* line 1:
* host(IP address or name) port(5000) time-out(centiseconds) mcast_addr mcast_port mcast_interface
* For host, it is recommended to use an alias from /etc/hosts to avoid
*  potential nameserver problems and hide IP/FQDN.
* Use only the first three tokens for no multicast
* example: remote host uses a long time-out
* rdbec      5000 500 239.0.2.30 20023 eth0
* example: local host uses a short time-out
* rdbec      5000 100 239.0.2.30 20023 eth0
  rdbec      5000 500 239.0.2.30 20023 eth0
