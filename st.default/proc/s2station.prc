define  check2a1      00000000000
check2c1
enddef
define  check2a2      00000000000
check2c2
enddef
define  check2c1      00000000000
enddef
define  check2c2      00000000000
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
define  initi         00000000000
"welcome to the pc field system
sy=run setcl &
enddef
define  midob         00000000000
onsource
wx
cable
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
setup
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
tape=reset
enddef
define  setup         00000000000
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
rec_mode=16-8-1,0
rec=eject
enddef

