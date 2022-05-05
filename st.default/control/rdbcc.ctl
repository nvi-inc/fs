*rdbcc.ctl example file
* RDBE-C must be configured with multi-cast 239.0.2.30:20023
*
* line 1: host(IP address or name) port(5000) time-out(centiseconds)
* using an IP address avoids name server and potential network problems
* example: remote host uses a long time-out
*   127.0.0.1 5000  500
* example: local host uses a short time-out
*   127.0.0.1 5000 100
