#############################################################################
# Visual Tcl v1.20 Project
#

#################################
# GLOBAL VARIABLES
#
global avag; 
global avmbs; 
global busy; 
global cpos; 
global destip; 
global doslist; 
global fs; 
global host; 
global line; 
global m5lnk; 
global perc; 
global play; 
global plys; 
global port; 
global ppos; 
global rec; 
global recg; 
global recs; 
global refkey; 
global rmsec; 
global spos; 
global sscan; 
global stime; 
global totb; 
global totg; 
global tots; 
global tout; 
global transf; 
global trperc; 
global trstat; 
global widget; 
    set widget(c) {.mk5.f0.disk}
    set widget(perc) {.mk5.f0.perc}
    set widget(rev,.mk5.f0.disk) {c}
    set widget(rev,.mk5.f0.perc) {perc}
    set widget(rev,.mk5.f0.tran) {tr}
    set widget(tr) {.mk5.f0.tran}

#################################
# USER DEFINED PROCEDURES
#
proc init {argc argv} {
global port host sscan ppos rmsec m5lnk totb refkey tout recs plys stime doslist totg fs totb tots spos cpos rec play busy transf

set reply 0
if $argc {
    set host [lindex $argv 0]
    if { [scan [lindex $argv 1 ] "%d" port] == -1 } { set port 2620}
    set totb [lindex $argv 2 ]
} else { set host ""; set port 2620 ; set totb [expr pow(2,30)] }

set sscan 0
set ppos 0
set rmsec 2000
set m5lnk 0
set refkey [list status ]
set tout 2000
set recs 0
set plys 0
set stime -1
set rec 0
set play 0
set transf 0
set busy 0
set doslist 0
if {$totb != "" } { set totg [expr $totb/ pow(2,30)] } else { set totg 1000; set totb [expr $totg * pow(2,30)] }
set fs [expr $totb /600]
set tots 0
set spos 0
set cpos 0
}

init $argc $argv


proc {M5Connect} {host port} {
set s [socket $host $port]
fconfigure $s -buffering line -blocking 0
fileevent $s readable [list M5read $s]
return $s
}

proc {M5read} {sock} {
global m5lnk reply line
 	if { [catch {gets $sock line}] || [eof $sock]} { # l'ordine e' imperativo
		# end of file or abnormal connection drop
		close $sock
		.mk5.but18 config -bg gray
		set m5lnk 0

	} else {
	    if { [string first "position?" $line] == 1 || [string first "status?" $line] == 1 } {
		ref $line;   # pass reply to refresh procedure
	    } elseif {[string first "disk2net?" $line] == 1 || [string first "in2net?" $line] == 1 } {
		reftr $line;   # pass reply to transfer data refresh procedure
	    } else { set reply $line }; # reply to a generic command. Pass it to M5send
	}
}

proc {M5send} {cmd} {
global socket reply tout
if { [catch {puts $socket $cmd}] } { lnkclosed ;  return -1 }

scan $cmd %s kword;                    # retrive command keyword to match the reply
set it [after $tout lnkclosed];        # timeout detector

vwait reply
while { [string first $kword $reply] == -1 } { vwait reply } ; # try to chatch a valid response

after cancel $it;         # trigger off the timeout detector

set np [scan $reply "%s = %d" rkword err]

if {$np == 2 && $err == 0 } {; # it is a good reply
    .mk5.f0.ferr config -bg gray
    return 0
} else {
    if { $err == 4 } {  tk_messageBox -icon error -type ok -title Message -message "Error encoutered during attempt to execute a query!"
    } elseif { $err == 5 } {tk_messageBox -icon warning -type ok -title Message -message "Too busy. Retry later!"
    } elseif { $err == 6 } {tk_messageBox -icon error -type ok -title Message -message "Inconsistent or conflicting request!"
    } elseif { $err == 8 } {tk_messageBox -icon error -type ok -title Message -message "Parameter error!"
    } elseif { $err == 9 } {tk_messageBox -icon error -type ok -title Message -message "Mark5 indeterminate state!"
    } else { .mk5.f0.ferr config -bg red }
    return -2}
}

proc {hbeat} {} {
# lauch the refresh procedure every rmsec milisecond, only if the link is on
global m5lnk rmsec refkey socket

if { $m5lnk } {

    foreach i $refkey {if { [catch {puts $socket $i}] } { lnkclosed ;  return -1 } }; # on error close the socket

}

uplevel #0 set idref [after $rmsec hbeat]; # continuos refresh
}

proc {lnkclosed} {} {
global socket m5lnk
.mk5.but18 conf -bg gray
set m5lnk 0
catch [close $socket]
tk_messageBox -icon warning -type ok -title Message -message "Timeout reading Mark5. Connection closed!"
}

proc {null} {} {
# do nothing
}

proc {recoff} {} {
#
global spos ppos tots reply sdetails startb stopb refkey
  set refkey [list status ]
  for {set i $spos} {$i<=$ppos} {incr i} {
       .mk5.f0.disk create line $i 0 $i 50 -fill green -tags "used #$tots"
  }
  .mk5.f0.disk create line $ppos 0 $ppos 50 -fill black -tags "stop $tots"
  incr ppos

# update the scan list
  M5send "scan_set =$tots"
  set lerr [M5send "scan_check" ]
  if { $lerr == 0 } {
           set nc [string first ":" $reply]; set sdetails($tots) [string range $reply [expr $nc+2] end]
          .mk5.f0.scans delete end
          .mk5.f0.scans insert end $sdetails($tots)
          .mk5.f0.scans yview end
          .mk5.f0.ferr config -bg gray

  }
  M5send "scan_set =$tots"
  set lerr [M5send "scan_dir" ]
  if { $lerr != 0 } { return } else { scan $reply "%*s =%d :%d : %c :%e :%e" err snum sname startb($tots) stopb($tots) }
}

proc {recon} {} {
global tots spos ppos refkey
    incr tots
    set spos $ppos
    .mk5.f0.scans insert end "$tots:- recording....................................."
    .mk5.f0.scans yview end
    set refkey [list status position ]
}

proc {ref} {line} {
global fs socket recp recg avag perc totb tots ppos recs plys dstat doslist rec play busy transf

if { [string first "status" $line] == 1 } {
  set np [scan $line "%*s =%d : 0x%x " err m5sts]
  if { $np == 2 && $err == 0 } {
    .mk5.f0.ferr config -bg gray

# check recording status
    if { $m5sts & 0x0001} {.mk5.f0.ready config -bg green -text ready } else {set busy 1; .mk5.f0.ready config -bg yellow -text "busy!" }

# check recording status
    set i [expr $m5sts & 0x00c0]
    if { $i } {  
        if { $i == 0x0040 } {.mk5.f0.rec config -bg red } else {.mk5.f0.rec config -bg yellow };            # recording prematurely halted
        if { $rec == 0 } { recon }
        set rec 1
    } else  {.mk5.f0.rec config -bg gray
        if { $rec } { recoff }
        set rec 0
    }

# check play back status
    set i [expr $m5sts & 0x0300]
    if { $i } {
        if { $i == 0x0200 } {.mk5.f0.play config -bg yellow ;             # playback prematurely ended
        } else  {.mk5.f0.play config -bg green  }
         set play 1 
     } else { set play 0 ;.mk5.f0.play config -bg gray  } ;                 #reset to idle refresh state
     
    if { $rec == 0 && $play == 0 } { .mk5.f0.stop configure -bg orange  
    } else { .mk5.f0.stop conf -bg gray }
    set busy [expr $rec + $play + $transf ]
    if { $doslist && $busy == 0} { scanlist; set doslist 0 }; # if this is first stop, update scan list
  } else {
    .mk5.f0.ferr config -bg red
    .mk5.f0.ready config -bg gray -text unknown
  }
} elseif { [string first "position" $line] == 1 } {
  set np [scan $line "%*s =%d :%e " err recb ]
  if { $np == 2 && $err == 0 } {
   set recp [expr int($recb/$fs)]
   set recg [format "%5.2fGB" [expr $recb/pow(2,30)]]
   set avag [format "%5.2fGB" [expr ($totb-$recb)/pow(2,30)]]
   set perc [format "%5.2f" [expr $recb/$totb*100.]]
   .mk5.f0.ferr config -bg gray
   for {set i $ppos} {$i<=$recp} {incr i} {
       .mk5.f0.disk create line $i 0 $i 50 -fill red -tags "used #$tots"
   }
   set ppos $i
  } else {
    .mk5.f0.ferr config -bg red
  }
} else {  }
}

proc {reftr} {line} {
global socket trtype trstat reply trperc mbs orftime maxmbs ipref cpos stime avmbs ptrb refkey stime busy transf
set sb2 0
set atime [clock clicks -millisecond]

#parse disk2net or in2net reply
catch [scan $line "%s =%d : %s : %e : %e : %e" cmd err trstat sb currb endb ]; # parse reply to see how many parameters are returned
if { $err > 1} { set trstat  Error! ; return };                                 # error <=1 means valid reply
        


if {$trstat == "active" || $trstat == "sending"} { set busy 1;set transf 1;                 # a transfering mode is active

   if {$cmd == "!disk2net?" } {; # there are disk2net data
        set trfs [expr ($endb-$sb+1)/500.];                                 # the byte/pixel factor scale
        set npos [expr int(($currb-$sb)/$trfs)];                            # new pixel position
        set trperc [expr int(($currb-$sb)/($endb-$sb+1)*100)]
        set trtype disk2net
   } elseif {$cmd == "!in2net?" } {; # there are in2net data
        set currb $sb
        set sb 0
        set npos [expr $cpos+20]
        .mk5.fra18.01 delete all
        set trtype in2net
   } else { return };    # no data for graph update
   if { $sb2 == 0 } { set sb2 $sb}; # different startbyte pointer, in case we start after a data transfer

   for {set i $cpos } {$i < $npos } {incr i} {;                            # plot the bar graph
          .mk5.fra18.01 create line $i 0 $i 25 -fill green -tags sent
   }
   set cpos $i
   if {$cpos > 500 } {set cpos 0}
   set refkey "$trtype?";    # monitor the data transfer untill it finish

# compute the span time between measures
   if { $stime == -1 } { ; # mk5 is already transfering data at program start. Set to default all related variables
     set mbs 0
     set stime $atime
     set orftime $stime
     set maxmbs 0
     set avmbs 0
     set cpos 0
     set ptrb 0
     set sb2 $currb
     set ptrb $currb
   }
   set difft [expr ($atime-$orftime + 1)/1000.];                                 # + 1 to avoid by zero division
   set orftime $atime

   if { $ptrb == 0 } { set ptrb $currb};                                # first loop initialization
   set mbs [expr int(($currb-$ptrb)* 8/($difft * pow(2,20)))];              # the transfer rate in Mb/s
   if { $mbs > $maxmbs } { set maxmbs $mbs};                             # keep track of maximum
   set avmbs [format "%6.1f" [expr ($currb-$sb2) * 8 /(($atime-$stime+1)/1000. * pow(2,20))]]

# # plot the transfer rate toolbar

   .mk5.fra18.cmbs delete data
   for { set i [expr 100-$mbs/10] } {$i < 100} {incr i } {
          .mk5.fra18.cmbs create line 0 $i 20 $i -fill green -tags data
   }
   set i [expr 100-$maxmbs/10]
   .mk5.fra18.cmbs create line 0 $i 20 $i -fill red -tags data
   set i [expr 100-$avmbs/10]
   .mk5.fra18.cmbs create line 0 $i 20 $i -fill blue -tags data
   set ptrb $currb

# on disk2net monitor for the end of transfer
   if { $trtype == "disk2net" && $currb == $endb} {
            puts $socket "$trtype =disconnect"
            set busy 0; set transf 0
            set refkey status; #reset to normal refresh state
           .mk5.fra18.04 conf -bg gray
            .mk5.fra18.05 conf -bg gray
            .mk5.fra18.go conf -bg gray
            .mk5.fra18.end conf -bg gray
   }
} else { set busy 0; set transf 0}
}

proc {scanlist} {} {
# retrive basic disk parameters int the more affordable GB form and already recorded scans info
# in case MK5 is busy many info are not available. Try to arrange at the best


global socket err tots totg recg avag perc ppos fs totb reply startb stopb
set lerr [M5send "dir_info" ]
if { $lerr != 0 } { return }

set np [scan $reply "%*s =%d :%d :%e :%e :%f" err tots recb totb rems]
if { $np == 5 } {
   set avab [expr $totb-$recb]
   set fs [expr $totb/600]
   set totg [format "%5.2f" [expr $totb/pow(2,30)]]
   set recp [expr $recb/$fs]; set ppos [expr int($recp)+1]
   set recg [format "%5.2fGB" [expr $recb/pow(2,30)]]
   set avag [format "%5.2fGB" [expr $avab/pow(2,30)]]
   set perc [format "%5.2f" [expr $recb/$totb*100.]]
   .mk5.f0.disk delete all
   .mk5.f0.scans delete 0 end
   .mk5.f0.scans insert 0 "# : name : mode : submode : date&time : duration: sample : lost bytes"

# after a dir_info the scan is always set to the first
# crate the start point marker for each scan on percentage bar graph
   for {set i 1} {$i<=$tots} {incr i} {
       set lerr [M5send "scan_dir" ]
       if { $lerr != 0 } { return }

       set np [scan $reply "%*s =%d :%d :%s :%e :%e" err snum sname startb($i) stopb($i)]
       if { $np != 5} {set np [scan $reply "%*s =%d :%d :   :%e :%e" err snum startb($i) stopb($i)] }; # this to mach scans with no scan name
       if { $np == 5 || $np == 4} {
           set startp [expr int($startb($i)/$fs)]
           set stopp [expr int($stopb($i)/$fs)]
          .mk5.f0.disk create line $startp 0 $startp 50 -fill black -tags "start $snum"
          for {set j [expr $startp+1]} {$j < $stopp} {incr j} {
             .mk5.f0.disk create line $j 0 $j 50 -fill green -tags "used #$snum"
          }
          .mk5.f0.disk create line $stopp 0 $stopp 50 -fill black -tags "stop $snum"
          set ppos [expr $stopp +1]
          .mk5.f0.ferr config -bg gray
       } else {
          .mk5.f0.ferr config -bg red
       }
       update
    }
# retrive the scan details to be putted in scan list window
   for {set i 1} {$i<=$tots} {incr i} {
       set lerr [M5send "scan_check"]
       if { $lerr != 0 } { return }

       set np [scan $reply "%*s =%d " err ]
       set nc [string first ":" $reply]; set sdetails($i) [string range $reply [expr $nc+2] end]
       .mk5.f0.scans insert end $sdetails($i)
       .mk5.f0.scans yview end
       .mk5.f0.ferr config -bg gray
       update
    }

  .mk5.f0.ferr config -bg gray
} else {
  .mk5.f0.ferr config -bg red
  tk_messageBox -icon info -type ok  -title Message  -message "Not able to retrive disk info. Could be Mark5 is recording!"
}
}

proc {main} {argc argv} {
# plot scale for throughput canvas
.mk5.fra18.cmbs create line 20 0 20 100
.mk5.fra18.cmbs create line 19 25 23 25
.mk5.fra18.cmbs create line 19 50 25 50
.mk5.fra18.cmbs create line 19 75 23 75
.mk5.fra18.cmbs create text 35 70 -text 1/4
.mk5.fra18.cmbs create text 35 45 -text 1/2
.mk5.fra18.cmbs create text 35 20 -text 3/4
}

proc {Window} {args} {
global vTcl
    set cmd [lindex $args 0]
    set name [lindex $args 1]
    set newname [lindex $args 2]
    set rest [lrange $args 3 end]
    if {$name == "" || $cmd == ""} {return}
    if {$newname == ""} {
        set newname $name
    }
    set exists [winfo exists $newname]
    switch $cmd {
        show {
            if {$exists == "1" && $name != "."} {wm deiconify $name; return}
            if {[info procs vTclWindow(pre)$name] != ""} {
                eval "vTclWindow(pre)$name $newname $rest"
            }
            if {[info procs vTclWindow$name] != ""} {
                eval "vTclWindow$name $newname $rest"
            }
            if {[info procs vTclWindow(post)$name] != ""} {
                eval "vTclWindow(post)$name $newname $rest"
            }
        }
        hide    { if $exists {wm withdraw $newname; return} }
        iconify { if $exists {wm iconify $newname; return} }
        destroy { if $exists {destroy $newname; return} }
    }
}

#################################
# VTCL GENERATED GUI PROCEDURES
#

proc vTclWindow. {base} {
    if {$base == ""} {
        set base .
    }
    ###################
    # CREATING WIDGETS
    ###################
    wm focusmodel $base passive
    wm geometry $base 200x200+0+0
    wm maxsize $base 1284 1009
    wm minsize $base 104 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm withdraw $base
    wm title $base "disk_serialMark5"
    ###################
    # SETTING GEOMETRY
    ###################
}

proc vTclWindow.mk5 {base} {
    if {$base == ""} {
        set base .mk5
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel
    wm focusmodel $base passive
    wm geometry $base 629x582+56+102
    wm maxsize $base 1284 1009
    wm minsize $base 104 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "vMk5  - Rev. 1.1- 14 Feb. 2003"
    frame $base.f0 \
        -borderwidth 2 -height 75 -relief groove -width 125 
    canvas $base.f0.disk \
        -background #ffffff -borderwidth 2 -height 264 -relief ridge \
        -width 378 
    bind $base.f0.disk <Button-1> {
        set stag [lindex [ .mk5.f0.disk gettags current] 1]
.mk5.f0.scans selection clear 0 end
.mk5.f0.disk itemconfig used -fill green
        if {$stag != ""} {
           scan $stag "#%%d"  sscan
           .mk5.f0.scans selection set $sscan
           .mk5.f0.scans activate $sscan
           .mk5.f0.scans see $sscan

           .mk5.f0.disk itemconfig $stag -fill blue
        } else { set sscan 0 }
    }
    label $base.f0.perc \
        -borderwidth 1 -font {{MS Sans Serif} 16} -text 0 -textvariable perc 
    button $base.f0.update \
        -command scanlist -font {Helvetica 8 normal} -text {force an update} 
    label $base.f0.reply \
        -borderwidth 1 -font {Helvetica 8 normal} -relief groove \
        -textvariable line 
    label $base.f0.recg \
        -borderwidth 1 -font {Helvetica 8 normal} -justify left -text 24.73GB \
        -textvariable recg 
    label $base.f0.t3 \
        -borderwidth 1 -font {Helvetica 8 normal} -text recorded: 
    label $base.f0.t4 \
        -borderwidth 1 -font {Helvetica 8 normal} -text {total size(GByte):} 
    label $base.f0.t6 \
        -borderwidth 1 -font {Helvetica 8 normal} -text available: 
    label $base.f0.avag \
        -borderwidth 1 -font {Helvetica 8 normal} -justify left \
        -text 422.30GB -textvariable avag 
    button $base.f0.play \
        -background gray \
        -command {if {  $sscan == 0 } {
       tk_messageBox -icon warning -type ok -title Message -message "No scan selected!"
} else { puts $socket "play =on:$startb($sscan)"
    set refkey status } ; # only status query is allowed!} \
        -font {{MS Sans Serif} 12} -text play 
    button $base.f0.rec \
        -background gray \
        -command {set lerr [M5send "record =on:-" ]; # the space between cmd and "=" is crucial
if { $lerr == 0 } {
    scan $reply "%*s = %d" err
    if $err {.mk5.f0.ferr config -bg red }
}} \
        -font {{MS Sans Serif} 12} -text rec 
    listbox $base.f0.scans \
        -background #ebebeb -font {Helvetica 8 normal} \
        -xscrollcommand {.mk5.f0.hslist set} \
        -yscrollcommand {.mk5.f0.vslist set} 
    bind $base.f0.scans <Button-1> {
        set psscan $sscan
set sscan [.mk5.f0.scans curselection]
.mk5.f0.disk itemconfig #$psscan -fill green
if {$sscan != ""} {
  .mk5.f0.disk itemconfig #$sscan -fill blue
}
    }
    label $base.f0.t7 \
        -borderwidth 1 -font {Helvetica 8 normal} -text {scan list:} 
    button $base.f0.stop \
        \
        -command {if { $rec } {
  M5send "record =off"
} else {
    M5send "play =off"
}} \
        -font {{MS Sans Serif} 12} -text stop 
    scrollbar $base.f0.hslist \
        -command {.mk5.f0.scans xview} -orient horizontal 
    scrollbar $base.f0.vslist \
        -command {.mk5.f0.scans yview} 
    label $base.f0.t11 \
        -borderwidth 1 -font {Helvetica 8 normal} -text {Last MK5 reply:} 
    label $base.f0.t13 \
        -borderwidth 1 -font {{MS Sans Serif} 16} -text % 
    label $base.f0.l5 \
        -borderwidth 1 -font {{MS Sans Serif} 16} -relief raised \
        -text {Disk operations} 
    button $base.f0.ferr \
        -background gray -font {Helvetica 8 normal} -text error 
    button $base.f0.ready \
        -font {Helvetica 8 normal} -text ready 
    entry $base.f0.totalsz \
        -font {Helvetica 8 normal} -textvariable totg 
    bind $base.f0.totalsz <Key-Return> {
        set totb [expr $totg * pow(2,30) ]
set fs  [expr $totb * pow(2,30)/ 600]
    }
    frame $base.fra18 \
        -borderwidth 2 -height 75 -relief groove -width 125 
    canvas $base.fra18.01 \
        -background #ffffff -borderwidth 2 -height 264 -relief ridge \
        -width 378 
    entry $base.fra18.02 \
        -font {Helvetica 8 normal} -textvariable destip 
    label $base.fra18.03 \
        -borderwidth 1 -font {Helvetica 8 normal} \
        -text {Destination IP number:} 
    button $base.fra18.04 \
        \
        -command {set lerr [ M5send "disk2net =connect:$destip"]
if { $lerr } { set trstat Refused! 
  .mk5.fra18.04 conf -bg gray
  .mk5.fra18.go conf -bg gray
  .mk5.fra18.end conf -bg gray
} else {
  set trtype disk2net
  set cpos 0
  .mk5.fra18.01 delete all
  .mk5.fra18.04 conf -bg blue
  .mk5.fra18.go conf -bg green
  .mk5.fra18.end conf -bg orange
  set trstat Connected!
}} \
        -font {Helvetica 8 normal} -text {Disk to Net} 
    button $base.fra18.05 \
        \
        -command {set lerr [M5send "in2net =connect:$destip"]
if {$lerr == 0} { set trstat active
  .mk5.fra18.05 conf -bg blue
  .mk5.fra18.go conf -bg green
  .mk5.fra18.end conf -bg orange
 
} else { set trstat Refused!
  .mk5.fra18.05 conf -bg gray
  .mk5.fra18.go conf -bg gray
  .mk5.fra18.end conf -bg gray
 }

set trtype in2net
set cpos 0
.mk5.fra18.01 delete all} \
        -font {Helvetica 8 normal} -text {In to Net} 
    button $base.fra18.go \
        \
        -command {if { $trtype == "disk2net"} {
    if {  $sscan == 0 } {
       tk_messageBox -icon warning -type ok -title Message -message "No scan selected!"
	break
    } else { puts $socket "$trtype =on: :$startb($sscan):$stopb($sscan)" }

} else { puts $socket "$trtype =on" }

set mbs 0
set stime [clock clicks -millisecond]
set orftime $stime
set maxmbs 0
set avmbs 0
set cpos 0
set ptrb 0
set refkey "$trtype?"} \
        -font {Helvetica 8 normal} -text GO! 
    button $base.fra18.end \
        \
        -command {if { $trtype == "in2net" } { puts $socket "$trtype =off"  }
puts $socket "$trtype =disconnect"
set busy 0
set refkey status
set trstat Closed!
set stime -1
.mk5.fra18.04 conf -bg gray
.mk5.fra18.05 conf -bg gray
.mk5.fra18.go conf -bg gray
.mk5.fra18.end conf -bg gray} \
        -font {Helvetica 8 normal} -text End 
    label $base.fra18.trstat \
        -background #808080 -borderwidth 1 -font {Helvetica 8 normal} \
        -foreground #ffff00 -relief groove -text inactive \
        -textvariable trstat 
    label $base.fra18.trperc \
        -background #c0c0c0c0c0c0 -borderwidth 1 -font {{MS Sans Serif} 16} \
        -justify right -text 0 -textvariable trperc 
    label $base.fra18.l3 \
        -borderwidth 1 -font {{MS Sans Serif} 16} -text % 
    canvas $base.fra18.cmbs \
        -background #ffffff -borderwidth 2 -height 264 -relief ridge \
        -width 378 
    label $base.fra18.l4 \
        -borderwidth 1 -font {Helvetica 8 normal} -text {Av. trate (Mb/s):} 
    label $base.fra18.mbs \
        -borderwidth 1 -font {Helvetica 8 normal} -relief groove -text 0 \
        -textvariable avmbs 
    label $base.fra18.l5 \
        -borderwidth 1 -font {Helvetica 8 normal} -text 1Gb/s 
    label $base.fra18.t6 \
        -borderwidth 1 -font {{MS Sans Serif} 16} -relief raised \
        -text {Data Transfer operation} 
    label $base.fra18.t7 \
        -borderwidth 1 -font {Helvetica 8 normal} \
        -text {red - peak
blue - aver.} 
    button $base.but17 \
        -background #ff0000 \
        -command {set m5lnk 0
catch [after cancel $idref]
catch [close $socket] ; destroy . ; exit} \
        -font {{MS Sans Serif} 12} -text Quit 
    button $base.but18 \
        -background gray \
        -command {if {$m5lnk} {set m5lnk 0; .mk5.but18 conf -bg gray ;
           catch [after cancel $idref]; #cancel any programmed refresh
           catch [close $socket]; # if any close actual connection
         } else { 
             if {[catch {set socket [M5Connect $host $port]}]} { 
                .mk5.but18  conf  -bg  gray ; set  m5lnk  0 ;
                 tk_messageBox -icon warning -type ok -title Message  -message "No connection to Mark5! \n Is  IP  address  correct?\n \Is \it \Mark5A \server \running? "
             } else {  .mk5.but18  conf  -bg  green ;set  m5lnk  1 

                foreach i [ list disk2net? in2net? status? ] {
                   puts $socket $i;                                    	#  check  if  it  is busy
                   after  500 ; update;                                 #  wait  for  the  reply 
                   if $busy break;                                      #  jump if it is busy 
                }
                if { $busy == 0 }   { scanlist ;            		#  make  a  scan  list  only  if  MK5  is  in  idle  mode 
                } else { set doslist 1 }   ;               		#  to  remember  a  scan  list  at  first  stop 
   		hbeat 
             } 
        }} \
        -font {Helvetica 8 normal} -text connect 
    label $base.lab19 \
        -borderwidth 1 -font {Helvetica 8 normal} -text host: 
    entry $base.ent20 \
        -font {Helvetica 8 normal} -textvariable host 
    entry $base.ent21 \
        -font {Helvetica 8 normal} -textvariable port 
    label $base.lab22 \
        -borderwidth 1 -font {Helvetica 8 normal} -text port: 
    ###################
    # SETTING GEOMETRY
    ###################
    place $base.f0 \
        -x 5 -y 5 -width 615 -height 400 -anchor nw -bordermode ignore 
    place $base.f0.disk \
        -x 5 -y 230 -width 600 -height 50 -anchor nw -bordermode ignore 
    place $base.f0.perc \
        -x 285 -y 205 -width 49 -height 23 -anchor nw -bordermode ignore 
    place $base.f0.update \
        -x 515 -y 205 -width 90 -height 18 -anchor nw -bordermode ignore 
    place $base.f0.reply \
        -x 210 -y 325 -width 386 -height 17 -anchor nw -bordermode ignore 
    place $base.f0.recg \
        -x 75 -y 280 -width 66 -height 17 -anchor nw -bordermode ignore 
    place $base.f0.t3 \
        -x 15 -y 280 -anchor nw -bordermode ignore 
    place $base.f0.t4 \
        -x 445 -y 280 -anchor nw -bordermode ignore 
    place $base.f0.t6 \
        -x 210 -y 280 -anchor nw -bordermode ignore 
    place $base.f0.avag \
        -x 260 -y 280 -width 76 -height 17 -anchor nw -bordermode ignore 
    place $base.f0.play \
        -x 245 -y 370 -width 50 -height 25 -anchor nw -bordermode ignore 
    place $base.f0.rec \
        -x 195 -y 370 -width 50 -height 25 -anchor nw -bordermode ignore 
    place $base.f0.scans \
        -x 5 -y 40 -width 588 -height 146 -anchor nw -bordermode ignore 
    place $base.f0.t7 \
        -x 5 -y 25 -width 55 -height 15 -anchor nw -bordermode ignore 
    place $base.f0.stop \
        -x 295 -y 370 -width 50 -height 25 -anchor nw -bordermode ignore 
    place $base.f0.hslist \
        -x 5 -y 185 -width 603 -height 16 -anchor nw -bordermode ignore 
    place $base.f0.vslist \
        -x 590 -y 40 -width 16 -height 143 -anchor nw -bordermode ignore 
    place $base.f0.t11 \
        -x 115 -y 325 -anchor nw -bordermode ignore 
    place $base.f0.t13 \
        -x 345 -y 205 -width 19 -height 23 -anchor nw -bordermode ignore 
    place $base.f0.l5 \
        -x 200 -y 5 -width 215 -height 28 -anchor nw -bordermode ignore 
    place $base.f0.ferr \
        -x 90 -y 375 -width 36 -height 18 -anchor nw -bordermode ignore 
    place $base.f0.ready \
        -x 10 -y 375 -width 76 -height 18 -anchor nw -bordermode ignore 
    place $base.f0.totalsz \
        -x 535 -y 280 -width 71 -height 20 -anchor nw -bordermode ignore 
    place $base.fra18 \
        -x 5 -y 410 -width 525 -height 160 -anchor nw -bordermode ignore 
    place $base.fra18.01 \
        -x 20 -y 125 -width 500 -height 25 -anchor nw -bordermode ignore 
    place $base.fra18.02 \
        -x 25 -y 30 -anchor nw -bordermode ignore 
    place $base.fra18.03 \
        -x 30 -y 10 -anchor nw -bordermode ignore 
    place $base.fra18.04 \
        -x 25 -y 55 -width 70 -height 30 -anchor nw -bordermode ignore 
    place $base.fra18.05 \
        -x 25 -y 85 -width 70 -height 30 -anchor nw -bordermode ignore 
    place $base.fra18.go \
        -x 120 -y 70 -anchor nw -bordermode ignore 
    place $base.fra18.end \
        -x 155 -y 70 -anchor nw -bordermode ignore 
    place $base.fra18.trstat \
        -x 115 -y 100 -width 81 -height 17 -anchor nw -bordermode ignore 
    place $base.fra18.trperc \
        -x 250 -y 100 -width 34 -height 23 -anchor nw -bordermode ignore 
    place $base.fra18.l3 \
        -x 290 -y 100 -width 19 -height 23 -anchor nw -bordermode ignore 
    place $base.fra18.cmbs \
        -x 470 -y 25 -width 50 -height 100 -anchor nw -bordermode ignore 
    place $base.fra18.l4 \
        -x 380 -y 35 -anchor nw -bordermode ignore 
    place $base.fra18.mbs \
        -x 390 -y 55 -width 60 -height 17 -anchor nw -bordermode ignore 
    place $base.fra18.l5 \
        -x 475 -y 10 -width 34 -height 12 -anchor nw -bordermode ignore 
    place $base.fra18.t6 \
        -x 195 -y 5 -anchor nw -bordermode ignore 
    place $base.fra18.t7 \
        -x 410 -y 85 -anchor nw -bordermode ignore 
    place $base.but17 \
        -x 535 -y 540 -width 84 -height 30 -anchor nw -bordermode ignore 
    place $base.but18 \
        -x 535 -y 470 -width 84 -height 18 -anchor nw -bordermode ignore 
    place $base.lab19 \
        -x 535 -y 410 -width 27 -height 12 -anchor nw -bordermode ignore 
    place $base.ent20 \
        -x 535 -y 425 -width 86 -height 19 -anchor nw -bordermode ignore 
    place $base.ent21 \
        -x 575 -y 445 -width 46 -height 19 -anchor nw -bordermode ignore 
    place $base.lab22 \
        -x 535 -y 445 -width 22 -height 17 -anchor nw -bordermode ignore 
}

Window show .
Window show .mk5

main $argc $argv
