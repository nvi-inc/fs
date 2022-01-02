*dbbad.ctl example file
* one uncommented line with up to six fields:
*    host(IP address or name)
*    port(4000)
*    time-out(centiseconds)
*    multicast address
*    multicast port
*    multicast interface
* If there are no uncommented lines, DBBC(2)/DBBC3 access is disabled.
* For DBBC(2), the first three fields are required and no more can be used.
* For DBBC3, there must be either the first three fields or all six. If the
*    final three are missing, multicast reception is disabled.
* Using an IP address instead of a name avoids name server problems.
* DBBC2 example:
*  192.168.1.2 4000 500
* DBBC3 example:
*  192.168.1.2 4000 800 224.0.0.19 25000 eno2
