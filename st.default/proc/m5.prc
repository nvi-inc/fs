define  ready_disk    00000000000
mk5close
xdisp=on
"mount the mark5 disks for this experiment now
"recording will begin at current position
"enter 'mk5relink' when ready or
"if you can't get the mk5 going then
"enter 'cont' to continue without the mk5
xdisp=off
halt
disk_serial
disk_pos
enddef
define  change_pack   00000000000x
sy=fs.prompt "bank/vsn '$' should be changed"  &
xdisp=on
"the disk module that is not selected may now be replaced.
"
"the mark5 will not respond to commands from the fs
" for almost 20 seconds after the key is turned to "locked".
" turn the key to "locked" only when the FS will be
" idle for more than 20 seconds.
wakeup 
xdisp=off
enddef   
define  mk5panic      000000000000
"mk5panic - dls - 5 december 2003
disk_record=off
mk5=bank_set=inc;
!+3s
disk_serial
mk5=bank_set?
mk5=vsn?
enddef   
