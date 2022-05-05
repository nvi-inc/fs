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
CA=dev3,0
* default K4 devices
*R1=dev4,4
*V4=dev24,4
*VA=dev25,4
*LA=dev26,4
*VB=dev27,4
*LB=dev28,4
*T1=dev29,4
*supported keywords for general behavior (all devices):
*no_untalk/unlisten_after   - don't untalk & unlisten after read
*no_online                  - no onlie when opening board or converter
*no_write_ren               - don't remote enable before write, board only
*set_remote_enable          - remote enable when opening board
*no_interface_clear_board   - interface clear when opening board
*interface_clear_converter  - interface clear when opening converter
*interface_clear_after_read - adds i/c after each read