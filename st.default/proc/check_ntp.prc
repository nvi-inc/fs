define  check_ntp     22033234428x
sy=popen 'uptime 2>&1' -n uptime &
sy=popen 'ntpq -p 2>&1|grep -v "^[- x#]" 2>&1' -n ntpq &
enddef
