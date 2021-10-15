#!/usr/bin/env python
from sys import argv

from fesh2 import SchedServer

def main():
    code = argv[1]
    sched_server = SchedServer.SchedFileServer("/usr2/sched")
    sched_server.curl_setup("/usr2/control/netrc_fesh2","/dev/null",True)
    # get the schedule. Set check_delta_hours=0 to make sure we get the latest version
    # regardless of server
    (
        got_sched_file_from_server,
        new_from_server,
    ) = sched_server.get_sched(
        "https://cddis.nasa.gov/archive/vlbi",
        code,
        'skd',
        2020,
        "/usr2/sched",
        True,
        check_delta_hours=0,
    )
if __name__ == "__main__":
    main()
