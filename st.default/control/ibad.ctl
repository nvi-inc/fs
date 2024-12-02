* format XX=devn,value,to
* where XX    is 2 character upper case device code
*       dev   is literal
*       n     is one or two digit device IB address
*       value is 0 for talk/listen devices
*                1 for talk-only devices 
*                2 for listen-only devices
*               +4 if SRQ supported
*               +8 if no_write_ren for this device
*       to     is optional time-out time (integer microseconds)
*                 usable values are: 
*                   10, 30, 100, 300, ..., 30000000, 100000000
*                   default is 3000000 (3 seconds)
*                   values larger than  100000000 (10 seconds) are
*                          converted to 100000000 (10 seconds)
*                   other values rounded up to next longer usable value
*             
* OR if you want to use TCP/IP-based communication either directly or
*    via a device like the Prologix GPIB-to-ethernet adapter:
*             
* format YY=net,IP-address,port,/command1[/command2[/command3...]]
* where 'YY' is a 2-character identifier used to identify the device action
*       'net' is a literal used to specify that this is a network-based action
*       'IP-address' is the IP-address of the device in 'a.b.c.d' notation
*       'port' is the port number to use on the device
*        the command sequence is the set of commands to send to the device
*             
* The command sequence must start with the character to use as a separator
* to separate between the different commands in the command sequence.
* It has to be present even if there is only one command and can be any valid
* ASCII-character not used in any of the command(s).
*             
* The identifier 'YY' is not used to identify a device but a certain action
* for that device. Different actions for the same device should be specified
* separately with each action having a unique individual identifier.
*             
* You can mix devices connected via a GPIB-bus or via ethernet as you wish.
* IBCON will not look for a GPIB-card, if all devices in this file have been
* declared as ethernet devices.
*             
* Further documentation and examples on how to use devices connected via
* ethernet are given in the document 'general_ibcon.pdf'.
*             
CA=dev3,0
* default K4 devices
*R1=dev4,4
*V4=dev24,4
*VA=dev25,4
*LA=dev26,4
*VB=dev27,4
*LB=dev28,4
*T1=dev29,4
*supported keywords for general behavior (all devices connected via a GPIB-bus):
*no_untalk/unlisten_after   - don't untalk & unlisten after read
*no_online                  - no onlie when opening board or converter
*no_write_ren               - don't remote enable before write, board only
*set_remote_enable          - remote enable when opening board
*no_interface_clear_board   - interface clear when opening board
*interface_clear_converter  - interface clear when opening converter
*interface_clear_after_read - adds i/c after each read
