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
