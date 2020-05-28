*mk5ad.ctl example file
* line 1: host(IP address or name) port(2620) time-out(centiseconds)
* using an IP address avoids name server and potential network problems
* example: remote host uses a long time-out
*   127.0.0.1  2620 500
* example: local host could use a short time-out (100), but we found 500 is better
*   127.0.0.1 2620 500
