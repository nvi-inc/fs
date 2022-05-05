File: /usr2/fs/misc/m5/readme.txt   WEH 20020412

Support for M5 in FS 9.5.7

This document is divided into five sections:

1. Software, decribes the software commands used with the Mark 5 recorder, 
2. Caveats, describes warning and issues you should be aware of
3. Operations, describes how the system is intended to used operationally
4. Hardware, describes what the supported hardware configurations are
5. Installation, describes how to install the new syste,

SOFTWARE

There are a few new commads: "disc_start", "disc_end", "disc_pos",
"disc_check", "mk5", "mk5close", "mk5relink". These are documented in
the style of SNAP command manual pages at the end of this file. There
is one new standard procedure "ready_disc", documented at the end of
the file after the new commands.  There is one new control file,
"mk5ad.ctl", also documented at the end of this file after the new
procedure.

The usual "echo=on" mechanism can be used to record the raw
communication strings between the FS and Mark 5. String sent to the
Mark 5 are shown in square backets "[]"; string read from the Mark 5
are shown in angle brackets "<>".

As usual commands that encounter no error and have no data to log do
not show a response unless extended display ("xdisp=on") or extended
logging ("xlog=on") are turned on.

CAVEATS

The Mark 5 support has not be tested extensively, but it seems to be
reasonably robust. Please report any problems to
weh@vega.gsfc.nasa.gov.

If you specify a Mark 5 device in "mk5ad.ctl" file and a initial
connection cannot be made, the FS will not terminate. This means that
you can leave the mark 5 device defined in the control file even if it
is truned off or otherwe unreachable. After an initial failure to
connect, the FS will try to establish a connect for each subsequent
Mark 5 command (except "mk5close") until a connection is made.

It is important to specify an IP address for the Mark 5 in the
"mk5ad.ctl" as opposed to a host name. If a host name is used and
there is some problem with the domain name server it wil be impossible
to connect to the Mark 5. Another possible problem is that for some
network problems, it is impossible to make the connection to the
domain name server "time-out" and abort in a short amount of time. In
this case the FS will hang for a substantial amount of time. The later
risk is unlikely to occur and in fact many common problems are handled
well by the time-out mechanism. However, both of these risks are, as
far as we can tell, completely eliminated by using an IP address. It
may also be possible to eliminate the risk by placing the mark 5
hostname and IP address in the /etc/hosts file, but this hasn't been
tested.

If a host name is and the connection attempt hangs and doesn't
time-out, the only solution is to make sure the window focus is in the
window you started the FS in and press Control-C to cause it to die
(sorry about this, but don't use host names if you want to avoid it).

After a connection is established, the FS is able to detect time-outs
when communicating with the Mark 5 except possibly in some
pathological cases that haven't been encountered yet. If the Mark 5
times-out after a connect has been established, it will attempt to
re-connect to it. This should work well, but if you get a hang, use
the method described above and contact Ed (weh@vega.gsfc.nasa.gov)
with as much information about what was happening as you can.

Some mode limitations are also described in the Operations section.

OPERATIONS

The Mark V recorder is currently supported in a "piggyback" mode only
for test observations with the Intensive UT1 measurements between
Kokee and Wettzell.

To use the piggyback mode, utilize option (13) in DRUDG to tell it
that you want this mode. DRUDG will then insert the necessary commands
into the *.snp file for the experiment. No other changes are made for
back-ends with VLBA formatters.  For Mark IV systems, the "trackform"
set-up is modified in the *.prc file to write the same data to the
head 2 output of the formatter as is going to head 1.

The piggyback observations are fairly straightforward. The disc is
started ("disc_start=on") and stopped ("disc_stop") along with the
recording of "valid" data on the tape. The disc position is recorded
("disc_pos") in the log before each start and after each stop. After
each observation a simple check ("disc_check") is made that data was
recorded. No error message is issued if the check finds no data, but
this provides a record of what was or was not found on the disc for
subsequent trouble-shhoting. The only other difference in that the
"ready_disc" procedure is invoked by the schedule to: disable the link
to the Mark 5 ("mk5close"); prompt the operator to insert the discs
(As part of inserting the discs. the operator may need to terminate
the Mark 5 recorder's control program and restart it. This can be done
via the Mark 5's console or an "xterm" logged into the Mark 5,
wherever the control program was started from.  Please check with any
documentation provided with the Mark 5 on its operations for more
details.); after the discs are ready, the operator enters the SNAP
command "mk5relink", the connection to the Mark 5 is resestablished;
the disc serial numbers are recorded ("disc_serial") in the log; and
the byte position ("disc_pos") is recorded in the log. If it is
impossible to re-establish the link to the Mark 5, the schedule can be
continued without the Mark 5 by entering the SNP command "cont", but
in this case all the subsequent Mark5 command will generate errors
until it is possible to establish a connection.

Operation of the Mark 5 recorder itself isn't covered here in any
detail. It should be covered in any documentation, training, technical
assistance that is provided with the Mark 5. However, a few points are
summarized here with emphasis on points of interaction with the
FS. The control program for the Mark 5, "Mark5A", must be started for
the system to be operational. This can be done either on the Mark 5
console (if one exists) or by logging on to it from an xterm. The
program is started running in background by entering "Mark5A &". If
you want debug output, put a zero "0" before the ampersand, as in
"Mark5A 0 &". When it says "ready", it is okay for the FS to be
started. To terminate the program, enter "EndM5". When it says the
"the end", it is free and clear. This can be done while the FS is
still running and if the program is subsequently restarted the FS will
reconnect on the next Mark 5 command that is executed. It may be
necessary to stop the program before removing discs and restarting it
after inserting discs. The FS and the Mark5A program will operate more
cleanly if you close the FS connection (with "mk5close") before
stopping the program and re-establishing a connection (with
"mk5relink") after re-starting it. The "ready_disc" procedure uses
this method.

One issue that is not resolved at the time of the writing of this
document is how "erasing" disk will be handled. There are arguments
for it being done either at the correlator or at the stations. In the
event that it needs to be done at the stations, the command "mk5=reset
erase" can be used. This will cause all data recorded on the disks to
be unrecoverablely erased. It should not be used as a normal part of a
schedule, but only to re-initialize the disks after they are initially
received at the station. Extreme care should be exercised when using
this command, since it is equivalent of degaussing a tape. The
possibility of an inadvertant erasure at a station is one of the
arguments for this operation being done at the correlator before discs
are shipped.

Currently only modes that use "trackform" to set-up the formatter are
supported. In other words, simple Mark 3 modes are not supported.

Another temporary mode restriction is that only modes that record all
32 tracks can be used. Any mode can be made to do this by assigning
data to any unused tracks.

HARDWARE

Currently only two hardware configurations are supported: (1) VLBA
formatter in which case the Mark 5 recorder is plugged into output for
recorder 2, and (2) a Mark IV formatter, in which case the head 2
outputs should be unplugged from the recorder and the Mark 5 should be
plugged in.

INSTALLATION

If you are still using a version earlier than 9.5.3, you should
upgrade to 9.5.3 first. Please contact Ed (weh@vega.gsfc.nasa.gov) if
this is a problem doing this. If you are using 9.5.3, it is fairly
painless to install the new version.

(1) Place the archive fs-9.5.5.tar.gz on /tmp.

(2) Stop the FS

(3) As "root", execute:

    cd /
    tar -xzf /tmp/fs-9.5.5.tar.gz
    cd /usr2
    ln -sfn fs-9.5.5 fs

(4) As "prog", execute:

    cd /usr2/fs
    make

(5) When the "make" completes, please type "make" again. If no errors
appear after this "make", everything was successful.

(6) Set-up the "mk5ad.ctl" control file. As oper:

    cd /usr2/control
    cp /usr2/fs/st.default/control/mk5ad.ctl .

Edit the file "/usr2/control/mk5ad.ctl" and enter the address, port,
and time-out for the Mark 5 recorder. Using the IP address instead of
the host name is strongly recommended. If you only have the host name,
it is easy to look-up its address with "nslookup". The initial port
number is 2620. It is unknown what the correct time-out should be.
Initially, 100 is recommmended if the Mark 5 is on the local network;
500 for a remote device. If time-outs occur these values can be
increased.

(7) Append "ready_disc" to your station.prc file. As "oper":

    cd /usr2/proc
    cat /usr2/fs/st.default/proc/m5.prc >> station.prc

(8) As "oper", try the FS. It should be available for use immediately.
There should be no need to reload station software or reboot.

----------------------------------------------------------------------------
disc_check - check Mark 5 recorded data

Syntax: DISC_CHECK

Response: DISC_CHECK/<format>,<tracks><time>,<pos>,<period>,<??>,

<format>: mark4, vlba, test, or ?
<tracks>: 8, 16, 32, 64
<time>:   time tag read
<pos>:    byte position of ??
<period>: track frame period (seconds)
<??>:     ??

If <format> is ?, the remaining fields are not valid.

This command sets the read pointer 1 mega-byte before the current
write pointer location and attemps to a data_check. The displayed
parameters are the output of the low-level Mark 5 data_check
command. A future version will allow the position of the read pointer
to be set explicitly, but this can be done with mk5 commands. To check
at positon "pos":

mk5=play off pos,data_check?
----------------------------------------------------------------------------
disc_end - end Mark 5 recording 

Syntax: DISC_END

Response: none

Stops recording.
----------------------------------------------------------------------------
disc_pos - Mark 5 pointer position

Syntax: DISC_POS

Response: DISC_POS/<write_pointer>,<read_pointer>

<write_pointer>: next position for write operations
<read_pointer>:  next position for readw operations
----------------------------------------------------------------------------
disc_serial - Mark 5 disc serial numbers

Syntax: DISC_SERIAL

Response: DISC_SERIAL/<serial1>,<serial2>,...,<serial16>,

<serialN>: disc N serial number, null if no disc is inserted in that slot
----------------------------------------------------------------------------
disc_start - start Mark 5 recording 

Syntax: DISC_START=<on>,<scan_name>

Response: DISC_START/<on/off>

<on>:       "on" only, starts Mark 5 recording
<scan_name>: string up to 16 characters, default is current scan_name
             command parameter value
<on/off>:    monitor only: on (recording) or off (not recording)

This command may be given only with either one parameter "on" to start
recording or with no parameter to monitor whether recording is on or
off. To stop recording use "disc_end".

Normally <scan_name> is taken by default as the scan name defined by
the most recent scan_name=... command. The <scan_name> parameter
allows the value used for this recording to over-written. It does not
change the actual scan name. The scan is sent to the Mark 5 to
identify the scan being recorded.
----------------------------------------------------------------------------
mk5 - Low-level mk5 interface command

Syntax: MK5=<command>,...

Response: MK5/<response>

<command>:  low-level Mark 5 command or query
<response>: response from the Mark 5

Multiple <command> paramaters can be sent with one MK5 command by
separating them comma. The <response> for each command goes in a
separate entry.
----------------------------------------------------------------------------
mk5close - close mk5 connection

Syntax: MK5CLOSE

Response: none

This command can be used to close the connection to a Mark 5
recorder. It is recommended that this be done prior to shutting down
the Mark 5 control program for a disc swap.
----------------------------------------------------------------------------
mk5relink - re-establish mk5 connection

Syntax: MK5RELINK

Response: none

This command can be used to open a new connection to the Mark 5
recorder after its control program has been restarted or its power has
been cycled. This is useful for example after a disk swap.
----------------------------------------------------------------------------
Standard ready_disc procedure:

mk5close
xdisp=on
"mount the mark5 discs for this experiment now
"recording will begin at current position
"enter 'mk5relink' when ready or
"if you can't get the mk5 going then
"enter 'cont' to continue without the mk5
xdisp=off
halt
disc_serial
disc_pos
----------------------------------------------------------------------------
mk5ad.ctl control file:

*mk5ad.ctl example file
* line 1: host(IP address or name) port(2620) time-out(centiseconds)
* using an IP address avoids name server and potential network problems
* example: remote host uses a long time-out
*   mark5-04.haystack.mit.edu
*   192.52.61.178  2620 500
* example: local host uses a short time-out
*   sirius
*   128.183.107.27 2620 100
----------------------------------------------------------------------------
