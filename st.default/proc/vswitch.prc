define  prepass       00000000000
wakeup
xdisp=on
" mount the next tape without cleaning the tape drive.
" use the label command when finished.
halt
xdisp=off
check=*,-tp
rec=load
!+10s
tape=low,reset
sff
!+5m27s
et
!+9s
wakeup
rec=release
xdisp=on
"drop vacuum loop, clean the tape drive thoroughly.
"re-thread the tape. use the label command when finished.
halt
xdisp=off
rec=load
!+10s
srw
!+5m28s
et
!+9s
rec=unload
enddef
define  prepassthin   00000000000
wakeup
xdisp=on
" mount the next tape without cleaning the tape drive.
" use the label command when finished
halt
xdisp=off
check=*,-tp
rec=load
!+10s
tape=low,reset
sff
!+10m54s
et
!+9s
wakeup
rec=release
xdisp=on
"drop vacuum loop, clean the tape drive thoroughly.
"re-thread the tape. use the label command when finished.
halt
xdisp=off
rec=load
!+10s
srw
!+10m54s
et
!+9s
rec=unload
enddef
