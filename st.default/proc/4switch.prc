define  prepass       00000000000
wakeup
xdisp=on
" mount the next tape without cleaning the tape drive.
" use the label command when finished.
halt
xdisp=off
check=*,-tp,-hd
rec=load
!+10s
tape=low
sff
!+5m27s
et
!+9s
wakeup
xdisp=on
"drop vacuum loop, clean the tape drive thoroughly.
"re-thread the tape, establish vacuum.
"use the label command when finished.
halt
xdisp=off
rec=load
!+10s
tape=low
srw
!+5m28s
et
!+9s
enddef
define  prepassthin   00000000000
wakeup
xdisp=on
" mount the next tape without cleaning the tape drive.
" use the label command when finished.
halt
xdisp=off
check=*,-tp,-hd
rec=load
!+10s
tape=low
sff
!+10m54s
et
!+9s
wakeup
xdisp=on
"drop vacuum loop, clean the tape drive thoroughly.
"re-thread the tape, establish vacuum.
"use the label command when finished.
halt
xdisp=off
rec=load
!+10s
tape=low
srw
!+10m54s
et
!+9s
enddef
define  ready         00000000000
sxcts
rxmon
newtape
rec=load
!+10s
loader
label
check=*,tp
enddef
