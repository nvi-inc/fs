define  greplog       00000000000x
sy=xterm -name greplog -e sh -c 'grep $ /usr2/log/`lognm`.log|less' &
enddef   
