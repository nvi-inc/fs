File: /usr2/fs/misc/lba/readme.txt   JFQ 20021029

Support for LBA Data Acquisition System in FS 9.5.??

This document is divided into five sections:

1. Software, decribes the software commands used with the LBA DAS 
2. Caveats, describes warning and issues you should be aware of
3. Hardware, describes what the supported hardware configurations are
4. Operations, describes how the system is intended to used operationally
5. Scheduling, describes the VEX input to use for the LBA DAS
6. Installation, describes how to install the new system.
7, Appendices, containing the FS help files for the new commands etc.

SOFTWARE

There are a few new commands: "corNN", "ds", "ftNN", "ifpNN", "monNN"
and a version of "trackform" for the new combination of LBA rack and
S2 recorder.  These are documented in the style of SNAP command manual
pages at the end of this file.  There are two totally new standard
procedure libraries for the LBA rack and S2 recorder combination available
in /usr2/fs/st.default/proc namely ls2station.prc and l4s2station.  There
is one new control file in /usr2/fs/st.default/control, "dsad.ctl" (also
documented at the end of this file) plus additional lines at the end of
the control files equip.ctl and dev.ctl.

Communication with the LBA hardware is done through a new bus controller
process "dscon" which talks the requisite ATNF dataset protocol out of
a standard serial port.  The usual "echo=on" mechanism can be used to
record the raw communication strings between the FS and the dataset bus.
String sent to the dataset bus are shown byte by byte in square backets
"[]"; string read back from the dataset bus are shown likewise in angle
brackets "<>".  Please note that "dscon" attempts to asynchronise the
dataset communication, such that the response data for the previous
communication follows the current command data followed only by the
preliminary <ACK/BEL/NAK> of the current communication.  Thus the first
response will only contains an <ACK/BEL/NAK> and there is an additional
set of response data at the end corresponding to the last command.

As usual commands that encounter no error and have no data to log do
not show a response unless extended display ("xdisp=on") or extended
logging ("xlog=on") are turned on.

CAVEATS

The LBA support has not be tested extensively, but it seems to be
reasonably robust.  In particular, it would be wise to preform a fringe
test before using this for real experiments.  Please report any problems
to jon@hartrao.ac.za and/or weh@vega.gsfc.nasa.gov.

The behaviour mimics that of the MAT and MCB based racks, namely the
"dscon" communication process will only detect that the modules are
installed/not-installed when they are first commanded.  However be 
warned: in this case the formatter clock is actually in the S2 recorder,
so the LBA rack will not be accessed at all during FS initialization.

Furthermore, unlike other rack types, the current state of the hardware
cannot be read back from the LBA data acquisition system, but may only
be inferred from the software state defined by the commands sent to the
device.  Each IF processor (IFP - consisting of a High Res Sampler and
a Digital Filter module) will thus show up as "uninitialized" until
such time as it has been commanded into a specific state.  Since
re-commanding of certain parameters within each IFP can cause it to
stop producing data for up to 2 seconds, the LBA rack operates in a
so-called "fast setup" mode, where only changes in configuration are
actually sent to the hardware.  However if any fault is detected, in
particular that the hardware sensed a power-fail condition, all
devices are marked as "unitialized" so that the next setup command
will set everything up from cold as expected.

The total power detector in the IFP has insufficient resolution to
allow it to be used for system temperature calibration, though full
TPI/TSYS support for the LBA rack is included.  A second LBA4 variant
has been temporarily included where this TPI support is disabled and
that for Mark IV racks included in its place.  Hence if a Mark IV
rack is also available, its modules may be setup to mimic the IFPs
(the Mark IV rack setup commands have been deliberately left enabled
in the LBA4 variant) and their TPI detectors used for system calibration.

Although in principle there are 32 independent dataset addresses, the
FS has been compiled to support only two LBA data acquisition systems
simultaneously ie. IFPs 1 and 2 associated with the dataset address 'd1'
and IFPs 3 and 4 associated with the address 'd2' as specified in the
"dsad.ctl" control file.  Although the maximum number of DAS may be
changed in /usr2/fs/include/params.h and /us2/include/params.i and
the FS recompiled, it should be noted that the FS expects only up to
four independent IF inputs, currently assumed to map one-on-one with
the IFPs 1 through 4, so IFP 5 would then also be mapped to IF 1 and
so on. With the current recording capability of the S2 recorder, and
the design of the S2 output of the DAS, only one DAS is likely to be
in use for VLBI anyway so this is unlikely to prove a problem.

HARDWARE

Currently up to two LBA data acquisition systems may be controlled at
any one time.  Only one of the DAS would be connected directly to the FS
via a standard serial cable from the DATASET RS232 port on its backplane
to the "dscon" serial port on the FS computer as designated in the
dev.ctl control file.  Any additional DAS must then be daisy chained
onto the FS dataset bus using the DATASET 485 backplane connectors.

OPERATIONS

Typically one LBA data acquisition system would be in use for VLBI
purposes, each of its two IF processors setup independently using
the appropriate "ifpNN" command. The S2 recorder would be connected
to the common S2-C1 output on the DAS backplane either directly, or
through a special "kludge" cable which exchanges inputs IN_4 and IN_5
from the second IFP with IN_2 and IN_3 respectively from the first
IFP, as reflected by the "trackform" command setting.  The extended
features of the DAS, namely the correlator port output and the monitor
point analog outputs are independently controlled though the "corNN"
and "monNN" commands respectively, since they have no impact on the
VLBI (S2-C1) output.  Additionally, when the fine-tuner part of either
IFP processor is not in use by the main "ifpNN" setting, it may be
independently controlled using the corresponding "ftNN" command.
The low-level "ds" command is typically only used for dataset bus
diagnostic purposes.

Setting up of input levels and monitoring of operational status of
the LBA data acquisition system is done through the new FS "monit4"
display process, started either using "sy=xterm -e monit4&" or the
new hotkey sequence Ctrl-Shift-4.  Users of the old LBA_DAS.EXE
control program should feel quite at home!  The IFPs to display may
be selected by typing the appropriate number in the window, with odd
numbers selecting level-bar output and even numbers numeric output.
Typing 'q' in the window causes "monit4" to quit.  Note that running
this display causes "chekr" to poll the displayed IFPs once a second
so please avoid keeping the display running all the time unless you
know this does not have any untoward effects.

Please see the help files included below for more details of the
LBA snap commands and their interactions / caveats etc.

SCHEDULING

The digital filters in the LBA data acquisition system are capable of
unique sideband combinations.  Not only can they produce an upright
or inverted response centred on the local oscillator frequency ( which
is far flatter than the dual sideband responses), but a lower sideband
response can be inverted into an upper sideband response with respect
to "local oscillator frequency minus bandwidth/2" and similarly an upper
sideband into lower wrt "local oscillator frequency plus bandwidth/2"
ie. a single IFP is equivalent to two adjacent VC/BBCs when only upper or
lower sidebands are being used.

The standard scheduling software (SKED, SCHED etc) work in terms of
each channels being defined as an upper or lower sideband response
with respect to a given sky frequency.  Fortunately the idea that each
baseband convertor can only produce only one lower and one upper
sideband response with respect to the same frequency is not entrenched
and VEX quite happily accomodates the flipped sidebands of the LBA
digital filters.  However the centred filter response has no VEX equivalent,
though it can be described as a upper sideband to "frequency - bandwidth/2"
etc.  Given that the centred response is so much better,  DRUDG is set
to always use the equivalent centred filter whenever the IFP is required
to produce a single response whether originally upper or lower sideband.
Note that this means that the frequency that the IFP is set to will then
differ from the value one might otherwise naively expect.

The trackform information may be equally confusing as the "lower" sideband
output of an IFP may well be an upright response instead and furthermore
for a centred filter, both "upper" and "lower" sideband outputs carry the
same information.  The internal switching capability of the LBA system is
also severely limited so clearly canned setups will need to be carefully
constructed.

INSTALLATION

If you are still using a version earlier than 9.5.16, you should
upgrade to 9.5.16 first. Please contact Ed (weh@vega.gsfc.nasa.gov) if
this is a problem doing this. If you are using 9.5.16, it is fairly
painless to install the new version.

(1) Place the archive fs-9.5.??.tar.gz on /tmp.

(2) Stop the FS

(3) As "root", execute:

    cd /
    tar -xzf /tmp/fs-9.5.??.tar.gz
    cd /usr2
    ln -sfn fs-9.5.?? fs

(4) As "prog", execute:

    cd /usr2/fs
    make

(5) When the "make" completes, please type "make" again. If no errors
    appear after this "make", everything was successful.

(6) Remake your local software. To remake the software if you have
    standard station software "Makefile" configuration, the following
    steps should do the trick:

      cd /usr2/st
      make rmdoto rmexe all

(7) When the "make" completes, please type "make" again. If no errors
    appear after this "make", everything was successful.

(8) Reboot the computer.

(9) Add the lines for LBA rack support to the equip.ctl file. As oper:

      cd /usr2/control
      tail -5 /usr2/fs/st.default/control/equip.ctl >> equip.ctl

    Now edit equip.ctl and make sure there is no blank line between the
    Mark IV firmware version and the new LBA parameters. Fill in the
    number of LBA data acquisition systems connected, whether to switch
    the 160MHz anti-alias filters in or out and whether the systems get
    their input from the internal 8-bit samplers or from an external 4-bit
    source (typically only at the Australia Telescope Compact Array.)
    And of course if you actually want to use the LBA support, set the
    rack type to "lba".

(10) Set-up the "dsad.ctl" control file. As oper:

      cd /usr2/control
      cp /usr2/fs/st.default/control/dsad.ctl .

    Check that the dataset addresses correspond to those set by the
    jumpers on the backplane of each DAS, with 'd1' corresponding to
    the DAS you intend to use for VLBI recording ( which will then be
    IFPs 1 and 2 ) and 'd2' to a second DAS if required.

(11) Add the lines for the "dscon" ATNF dataset bus controller to the
    dev.ctl file. As oper:

      cd /usr2/control
      tail -2 /usr2/fs/st.default/control/dev.ctl >> dev.ctl

    Fill in the appropriate serial port device and required baud rate.

(12) If you are using the standard FS display layout and hot-keys, you
    will probably want to add support for the new "monit4" display process.
    As oper:

      cp /usr2/fs/st.default/oper/.Xresources ~/
      cp /usr2/fs/st.default/oper/.fvwmrc ~/

    and similarly as prog:

      cp /usr2/fs/st.default/prog/.Xresources ~/
      cp /usr2/fs/st.default/prog/.fvwmrc ~/

(13) For the new combination of LBA rack and S2 recorder, there is now a
    corresponding station library.  If your station is to operate with
    this combination of equipment then as oper:

      cd /usr2/proc

      cp /usr2/fs/st.default/proc/l4s2station.prc station.prc
        or
      cp /usr2/fs/st.default/proc/ls2station.prc station.prc

      chmod go+rw station.prc

    for LBA with and without Mark4 respectively and then customise it to
    suit your local settings.

(14) Update your stcmd.ctl file for the new format. The commands:

      cd /usr2/control
      /usr2/fs/misc/cmdctlfix4 stcmd.ctl

    should do it automatically.  You will need to rename or delete your
    old "stcmd.bak" if it already exists.  If all your station commands
    are hardware independent, i.e., the equipment bit fields are "FFFFFF",
    as they probably should be, this should work with no problems. The result
    for hardware independent commands should be "3FF3FF3FF".  You should
    check the contents of the file to make sure they are correct.

    If you haven't updated your "stcmd.ctl" file since installing 9.5
    your equipment bit fields may still be "1F1F". You can correct this
    before running "cmdctlfix4" by first running "cmdctlfix3" and
    renaming or deleting "stcmd.bak".

    If you haven't updated your "stcmd.ctl" file since installing 9.4,
    your equipment bit fields may still be "FF". You can correct this
    before running "cmdctlfix3" by first running "cmdctlfix2" and
    renaming or deleting "stcmd.bak".

    If you haven't updated your "stcmd.ctl" file since the S2
    equipment support was added, your equipment bits field may be
    still be "77". You can correct this before running "cmdctlfix2" by
    first running "cmdctlfix" and renaming or deleting "stcmd.bak".

    Please note that if your "stcmd.ctl" has been partially or
    incorrectly updated in the past, "cmdctlfix", cmdctlfix2",
    "cmdctlfix3", and "cmdctlfix4" will do the best they can and
    print a warning.

(15) As "oper", try out the new capabilities of the FS.


APPENDICES

An example of the dsad.ctl dataset address control file:
----------------------------------------------------------------------------
*dsad.ctl - LBA Dataset addresses
*Device Hex ID  Trailing Comment
d1        0	First DAS address  (IFP01,IFP02)
d2        1	Second DAS address (IFP03,IFP04)
----------------------------------------------------------------------------

The Field System help files for the new LBA commands:
----------------------------------------------------------------------------
                 cornn - IF processor Correlator port (LBA rack)
 
             Syntax:     cornn=type,source1,source2,delay
 
             Response:   cornn/type,source1,source2,delay
 
 
 Settable parameters:
             type        Either AT for output to a Australia Telescope 4-level
                         correlator or MB for use with a Multibeam 3-level
                         correlator.  Default is AT.
             source1     The source of the signal to be sent to either an AT
                         correlator or to channel 1 of a MB correlator that
                         is connected to the correlator port of IF processor nn.
                         Required value is one of:
                           BSU - the upper sideband output of the Band Splitter
                           BSL - the lower sideband output of the Band Splitter
                           FTU - the upper sideband output of the Fine Tuner
                           FTL - the lower sideband output of the Fine Tuner
                            32 - the full 32MHz output of the Band Splitter
                            64 - the raw 64MHz output of the Analog Sampler
                           USB - the default USB output ( including 32/64 ) as
                                 setup by the latest ifpnn command.
                           LSB - the default LSB output ( including 32/64 ) as
                                 setup by the latest ifpnn command.
                         Default is USB for AT correlator, LSB for MB.
             source2     The source of the signal to be sent to channel 2 of a
                         MB correlator, values as per source1.  Default is USB.
             delay       The clock delay in cycles to be applied to an AT
                         correlator output, either 0,1,2 or 3. Default is 0.
 
 Monitor-only parameters:
              none
 
 Comments: The pinouts differ quite markedly from AT to MB correlator mode.
 
 Note that the appropriate 4-level or 3-level statistics must be setup using
 the ifpnn command for accurate absolute calibration of resulting spectra.
 
 See also: ftnn, ifpnn, monnn.
----------------------------------------------------------------------------
           ds - low level dataset communications (via DSCON)
 
 Syntax:      ds=mnem,func,data
 
 Response:    ds/ack,data 
              ds/ack,warn,err
 
 Settable parameters:
            mnem         Dataset 2 char mnemonic from /usr2/control/ds_ad.ctl
            func         Dataset function in the range 0 to 511. No default.
            data         Hexadecimal data to be sent to module.  Required to
                         initiate write, use null parameter to read.
 
 Monitor-only parameters:
            ack          Response code:
                           ACK if successful,
                           BEL if the Dataset gave a warning
                           NAK if the Dataset gave an error
                           NUL if the driver had a problem
            data         Response of module, only generated on successful
                         read requests.
            warn         Current contents of Dataset warning register.
            err          Current contents of Dataset error register.
                         ( will contain error number if driver problem )
----------------------------------------------------------------------------
                      ftnn - IF processor Fine Tuner (LBA rack)
 
 Syntax:     ftnn=source,freq,bandwidth,mode,offset,phase,test
 
 Response:   ftnn/source,freq,bandwidth,mode,offset,phase,test
 
 
 Note: This command is only active when the corresponding ifpnn command has
       selected a band splitter only mode eg. SC1, AC1, DS2, DS4 or DS6.
       The maximum Fine Tuner input bandwidth is 16MHz ie. aliasing will
       occur if the Band Splitter mode has bandwidth of 32 or 64MHz.
 
 
 Settable parameters:
             source      The source of the signal to be connected to the Fine
                         Tuner input.  Required value is one of:
                           USB - the upper sideband output of the Band Splitter
                           LSB - the lower sideband output of the Band Splitter
                         Default is USB.
             freq        Frequency in MHz, value allowed is up to the bandwidth
                         currently selected in the Band Splitter.
                         Default is Band Splitter selected bandwidth / 2.
             bandwidth   Required filter bandwidth in MHz.  Allowed values are:
                          0.0625, 0.125, 0.25, 0.5, 1.0, 2.0, 4.0, 8.0, 16.0MHz
                         Value may not be larger than the Band Splitter selected
                         bandwidth or less than 1/16 of it.  Default is the Band
                         Splitter selected bandwidth.
 	    mode        Filter mode, one of:
                           NONE - bypass mode, output is a copy of input.
                                  ( bandwidth must be equal to Band Splitter )
                           DSB  - double sideband response about frequency.
                                  ( bandwidth up to half of Band Splitter )
                           SCB - single response centred on frequency (ie.
                                 equivalent to upper sideband at frequency -
                                 bandwidth/2).
                           ACB - alternative single response centred on 
                                 frequency, slightly wider than SCB but at the
                                 expense of additional ripple.
                         Default is NONE.
             offset      Frequency offset in MHz, value is added to the centre
                         value above, but via a different hardware register.
                         Allowed values are such that frequency plus offset lies
                         in the range 0 to the Band Splitter selected bandwidth.
                         Default is 0.0MHz.
             phase       Phase offset to be added to the local oscillator,
                         value between 0 and 360 degrees, used mainly for test
                         purposes.  Default is 0.0 degrees.
             test        Used to turn on a test mode where the Fine Tuner
                         output is the phase of the oscillator. Required value
                         is either ON or OFF.  Default is OFF. 
 
 Monitor-only parameters:
              none
 
 Comments: This command is intended to be used for test purposes only.  For
 VLBI recording etc. standard DSB or SCB mode should be used via ifpnn instead.
 
 See also: cornn, ifpnn, monnn.
----------------------------------------------------------------------------
                   ifpnn - IF processor (LBA rack)
 
 Syntax:     ifpnn=freq,bandwidth,mode,flipU,flipL,bitcode,mstats
                  or
             ifpnn=alarm     (to reset the 1PPS/5MHz status latches)
 
 Response:   ifpnn/freq,bandwidth,mode,flipU,flipL,bitcode,mstats,
                   sync/err,proc/ntrdy,TP
                  or
             ifpnn/ACK/NAK
 
 
 Settable parameters:
             freq        Effective frequency in MHz, value is usually 32.0
                         MHz ( or higher aliases at 96 or 160 MHz ) though a
                         limited amount of tuning is available depending on
                         bandwidth and filter mode.  No default.
             bandwidth   Effective filter bandwidth in MHz, default 2. Choices
                         for single centreband are:
                           0.0625, 0.125, 0.25, 0.5, 1, 2, 4, 8, 16, 32 or 64MHz
                           ( 64MHz available only in 1-bit sampling )
                         Choices for double sideband are:
                           0.0625, 0.125, 0.25, 0.5, 1, 2, 4, 8 or 16MHz.
             mode        filter mode, usually DSB, SCB or ACB though all of the
                         following are possible:
                           DSB - double sideband response about frequency,
                                 tuneability depending on bandwidth as follows:
                                   16.0 MHz  - not tuneable.
                                    8.0 MHz  - available at 24, 32, 40MHz.
                                    4.0 MHz  - tuneable up to +- 12.00MHz.
                                    2.0 MHz  - tuneable up to +- 14.00MHz
                                    1.0 MHz  - tuneable up to +- 7.000MHz
                                    0.5 MHz  - tuneable up to +- 3.500MHz
                                   0.25 MHz  - tuneable up to +- 1.750MHz
                                   0.125 MHz - tuneable up to +- 0.875MHz
                                  0.0625 MHz - tuneable up to +- 0.9375MHz
                           SCB - single response centred on frequency (ie.
                                 equivalent to upper sideband at frequency -
                                 bandwidth/2), tuneability depending on
                                 bandwidth as follows:
                                  64/32/16 MHz - not tuneable.
                                    8.0 MHz  - available at 12, 20-44 and 52MHz.
                                    4.0 MHz  - tuneable up to +- 14.00MHz.
                                    2.0 MHz  - tuneable up to +- 15.00MHz
                                    1.0 MHz  - tuneable up to +- 7.500MHz
                                    0.5 MHz  - tuneable up to +- 3.750MHz
                                   0.25 MHz  - tuneable up to +- 1.875MHz
                                   0.125 MHz - tuneable up to +- 0.9375MHz
                                  0.0625 MHz - tuneable up to +- 0.96875MHz
                           ACB - alternative single response centred on 
                                 frequency, slightly wider than SCB but at the
                                 expense of additional ripple, tuneablity as
                                 for SCB.
                           DS2 - double sideband reponse about frequency,
                                 produced only in band splitter, not tuneable
                                 and available only for 1, 2, 4, 8 and 16MHz.
                           DS4 - separated double sideband response about
                                 frequency, produced only in band splitter,
                                 not tuneable and available only for 8MHz.
                                 Response is equivalent to lower sideband at
                                 24MHz and upper sideband at 40MHz
                           DS6 - separated double sideband response about
                                 frequency, produced only in band splitter,
                                 not tuneable and available only for 8 MHz.
                                 Response is equivalent to lower sideband at
                                 16MHz and upper sideband at 48MHz
                           SC1 - single response centred on frequency,
                                 produced only in band splitter, not tuneable
                                 and available only for 1, 2, 4, 8, 16, 32
                                 and 64MHz.
                           AC1 - alternative single response centred on
                                 frequency, produced only in band splitter, not
                                 tuneable and available only for 1, 2, 4, 8, 16,
                                 32 and 64MHz.
                         Default is DSB.
                         (In addition for < 16MHz DSB or < 32MHz SCB, filters
                         may be mis-tuned up to bw/16 from nominal frequencies
                         quoted above.)
             flipU       Upper sideband/Centre band spectrum inverter, either
                         NAT for response upright in IF or FLIP for inverted.
                         Default is NAT.
             flipL       Lower sideband/Centre band spectrum inverter, either
                         NAT for response inverted in IF or FLIP for upright.
                         Default is NAT.
             bitcode     Either AT for Australian style true sign and magnitude
                         encoding or VLBA for Mark IV/VLBA compatible encoding.
                         Default is AT.
             mstats      Either 4LVL for use with VLBI recording and other true
                         4-level correlators or 3LVL for use with a 3-level
                         correlator.  See also cornn for more details on the
                         correlator output port.
                         Default is 4LVL.
 
 Monitor-only parameters:
            sync/err     5MHz, 1PPS reference signal status, sync or error.
            proc/ntrdy   digital filters status, processing or not ready.
             TP          total power reading, decimal (currently N/A).
 
 Comments: The limited frequency tuning range requires that the LBA DAS be used
 with a ( at least coarsely ) tuneable first LO and independant IFs if multiple
 VCs are to be emulated.
 
 Note that you must use one of the Band Splitter only modes eg, SC1 if you
 want to independently manipulate the Fine Tuner using ftnn.
 
 See also: cornn, ftnn, monnn.
----------------------------------------------------------------------------
           monnn - IF processor digital/analog monitors (LBA rack)
 
 Syntax:     monnn=bsana,ftana,ftdig
 
 Response:   monnn/bsana,ftana,ftdig
 
 
 Settable parameters:
             bsana       Source of the Band Splitter analog monitor output,
                         either USB or LSB.
             ftana       Source of the Fine Tuner analog monitor output, either
                         USB or LSB.
             ftdig       Source of the 10-bit Fine Tuner digital output port,
                         either USB or LSB.
 
 Monitor-only parameters:
              none
 
 Comments: The analog monitor ports are generated by a synchronous D-to-A so
 the frequency response will show sinc(x) aliasing.  The Fine Tuner digital
 output port is expected to be used for a digital total power detector in due
 course, to allow true in-band system temperature determination.
 
 See also: cornn, ftnn, ifpnn.
----------------------------------------------------------------------------
               trackform - sampler assignments (LBA rack)
 
 Syntax:     trackform=track,sampler,track,sampler, ...
 
 Response:   trackform/track,sampler,track,sampler, ...
 
 
 Settable parameters:
           track     S2 recorder track number whose sampler assignment
                     will follow, must be between 0 and 15. Currently
                     only 0 through 7 are implemented.
           sampler   the sampler that will be mapped to the preceding
                     track, 0, or in the form nnsd(+m), where nn=ifp
                     number (1 through 16), s=sideband ( u or l), d is
                     the data bit (s or m) and  m is the lag 0, 1, 2,
                     or 3 when fan out is being used.
 
 Comments: 
 The tracks and samplers must appear in pairs.  Multiple commands are allowed 
 because all of the pairs may not fit on a single line.  Currently this version
 of trackform is mainly advisory and any combination that does not match a valid
 cable combination will be rejected.  This command has been implemented mainly
 to allow the scheduling software to be generalised and will need some further
 hardware to implement all possible combinations.  The track numbers correspond
 directly to in00 through in15 on the S2 C1 input cable as expected.
 
 Recognised cabling combinations are:
 
                 S2 recorder connected directly to DAS 1
 
              IFP1                                      IFP2
     -----------------------                   -----------------------
     0,1us,1,1um,2,1ls,3,1lm      bw<32MHz     4,2us,5,2um,6,2ls,7,2lm
               or                                        or
     0,1ls,1,1lm,2,1us,3,1um                   4,2ls,5,2lm,6,2us,7,2um
               or                                        or
 0,1us+0,1,1um+0,2,1us+1,3,1um+1  bw=32MHz  4,2us+0,5,2um+0,6,2us+1,7,2um+1
               or                                        or
 0,1us+0,1,1us+1,2,1us+2,3,1us+3  bw=64MHz  4,2us+0,5,2us+1,6,2us+2,7,2us+3
 
 
              S2 recorder connected through "kludge" to DAS 1
 
              IFP1                                      IFP2
     -----------------------                   -----------------------
           0,1us,1,1um            bw<32MHz           2,2us,3,2um
               or                                        or
           0,1ls,1,1lm                               2,2ls,3,2lm
 
 The "kludge" is a short section of cable that interchanges tracks 2 and 3
 with tracks 4 and 5 respectively when inserted.  The only hardware in use
 to implement the above scheme is usb/lsb choosers on each IFP s2 output
 pair ie. 0 and 1, 2 and 3 for ifp1 etc.
 
 In addition to the above, the current version of trackform will also accept
 combinations where the S2 recorder is connected to DAS N ie. output is from
 IFP 2N-1 and 2N instead of 1 and 2.
 
 Note: The trackform command does not check for viability of the requested
 track layout in terms of actual hardware support, but informative messages/
 warnings are printed as and when the DAS is setup.  CAVEAT EMPTOR !!
 The current intention is to add a digital cross-point switch in due course
 which will support all reasonable combinations.
----------------------------------------------------------------------------

The new station procedure library ls2station.prc
----------------------------------------------------------------------------
define  sched_initi   00000000000
enddef
define  sched_end     00000000000
enddef
define  caloff        00000000000
"turn cal off
enddef
define  calon         00000000000
"turn cal on
enddef
define  caltsys       00000000000
tpi=formifp
calon
!+2s
tpical=formifp
tpidiff=formifp
caloff
caltemp=formifp
tsys=formifp
enddef
define  dat           00000000000
ifp01=reset
ifp02=reset
ifpxxf
ifdxx
enddef
define  fastf         00000000000
ff
!+$
et
enddef
define  fastr         00000000000
rw
!+$
et
enddef
define  ifdxx         00000000000
lo=
lo=lo1,8265.00,usb,lcp,1
lo=lo2,8265.00,usb,rcp,1
enddef
define  ifdvc         00000000000
lo=
lo=lo1,4656.00,usb,lcp,1
enddef
define  ifpxxf        00000000000
ifp01=160.00,16.0,scb,nat
ifp02=160.00,16.0,scb,nat
enddef
define  ifpvcf        00000000000
ifp01=160.00,16.0,dsb,nat,flip,vlba
enddef
define  initi         01312084428
"welcome to the pc field system
sy=run setcl &
enddef
define  midob         00000000000
onsource
wx
cable
ifp01
ifp02
"add your station command to measure the gps to fm output clock offset
"gps-fmout=c2
sy=run setcl &
enddef
define  midtp         00000000000
enddef
define  min15         00000000000
wx
cable
enddef
define  overnite      00000000000
log=overnite
setupa=0
check=*,-tp
min15@!,15m
enddef
define  postob        00000000000
enddef
define  preob         00000000000
onsource
enddef
define  ready         00000000000
newtape
loader
label
check=*,tp
enddef
define  loader        00000000000
rw
!+20s
et
!+10s
tape=reset
enddef
define  setupa        00000000000
pcalon
ifpxxf
ifdxx
trackforma
rec_mode=32x4-2,$
user_info=1,label,station
user_info=2,label,source
user_info=3,label,experiment
user_info=3,field,<none>
user_info=1,field,,auto
user_info=2,field,,auto
data_valid=off
enddef
define  setupv        00000000000
pcalon
ifpvcf
ifdvc
trackformv
rec_mode=32x4-2,$
user_info=1,label,station
user_info=2,label,source
user_info=3,label,experiment
user_info=3,field,<none>
user_info=1,field,,auto
user_info=2,field,,auto
data_valid=off
enddef
define  trackforma    00000000000
trackform=
trackform=0,1us,1,1um,2,2us,3,2um
enddef
define  trackformv    00000000000
trackform=
trackform=0,1ls,1,1lm,2,1us,3,1um
enddef
define  unlod         00000000000
check=*,-tp
unloader
xdisp=on
"**dismount this tape now**"
wakeup
xdisp=off
enddef
define  unloader      00000000000
et
rec=eject
enddef
define  pcalon        00000000000
"no phase cal control is implemented here
enddef
define  pcaloff       00000000000x
"no phase cal control is implemented here
enddef
define  checkcrc      00000000000x
"comment out the following lines if you do _not_ have a mark iii decoder
"decode=a,crc
"decode
enddef
----------------------------------------------------------------------------
