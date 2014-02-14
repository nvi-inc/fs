*mk5ad.ctl example file
* line 1: host(IP address or name) port(2620) time-out(centiseconds)
* using an IP address avoids name server and potential network problems
* example: remote host uses a long time-out
*   mark5-04.haystack.mit.edu
*   192.52.61.178  2620 500
* example: local host could use a short time-out (100), but we found 500 is better
*   sirius
*   128.183.107.27 2620 500
