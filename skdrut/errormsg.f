      subroutine errormsg(iret,ierr,cgroup,luscn)

C ERRORMSG prints informatiave error messages about VEX
C parsing and interpreting errors. Errors that sked/drudg
C catch are printed from within the VUNPxxx routines.
C A positive IERR returned from the VUNPxxx routines means 
C there was a problem in the parser and IERR indicates which 
C field. 
C A negative IERR returned from the VUNPxxx routines means
C an error in the content that sked/drudg caught and an
C error message is printed at that time, but no message
C is printed by this routine.

      include '../skdrincl/skparm.ftni'

C History
C 970122 nrv New.
C 970718 nrv Correct some of the error numbers to be consistent
C            with the VUNPxxx routines.

C Input:
      integer iret ! return from the parser
      integer ierr ! indicates type of error
      character*12 cgroup ! group name for ierr
      integer luscn ! unit to print the message on

C Local
      character*128 cmsg
      integer trimlen

C 1. If iret is non-zero, print the appropriate message.

      if (iret.ne.0) then
        if (iret.eq.-3) cmsg='-3 = not found'
        if (iret.eq.-4) cmsg='-4 = variable/def/name did not fit '
        if (iret.eq.-6) cmsg='-6 = field out of range'
        if (iret.eq.-7) cmsg='-7 = not a valid real or integer'
        if (iret.eq.-8) cmsg='-8 = unknown units'
        write(luscn,9100) cmsg(1:trimlen(cmsg))
9100    format('ERRORMSG01 'a)
      endif

C     2. Print error messages by group.

      if (ierr.ne.0) then
        if (cgroup(1:7).eq.'ANTENNA') then
          if (ierr.eq.1) cmsg='1 = antenna name'
          if (ierr.eq.2) cmsg='2 = axis type'
          if (ierr.eq.3) cmsg='3 = axis offset'
          if (ierr.eq.4) cmsg='4 = slewing rates and constants'
          if (ierr.eq.5) cmsg='5 = antenna limits'
          if (ierr.eq.6) cmsg='6 = antenna diameter'
        else if (cgroup(1:3).eq.'BBC') then
          if (ierr.eq.1) cmsg='1 = BBC_def statements'
          if (ierr.eq.11) cmsg='11 = BBC ref'
          if (ierr.eq.12) cmsg='12 = physical BBC number'
          if (ierr.eq.13) cmsg='13 = IFD ref'
        else if (cgroup(1:3).eq.'DAS') then
          if (ierr.eq.1) cmsg='1 = recorder type'
          if (ierr.eq.2) cmsg='2 = rack type'
          if (ierr.eq.3) cmsg='3 = terminal ID'
          if (ierr.eq.4) cmsg='4 = terminal name'
          if (ierr.eq.5) cmsg='5 = number of headstacks'
          if (ierr.eq.6) cmsg='6 = maximum tape length'
          if (ierr.eq.7) cmsg='7 = number of recorders'
          if (ierr.eq.8) cmsg='8 = tape motion'
        else if (cgroup(1:5).eq.'EXPER') then
          if (ierr.eq.1) cmsg='1 = experiment name'
          if (ierr.eq.2) cmsg='2 = experiment description'
          if (ierr.eq.3) cmsg='3 = PI name'
          if (ierr.eq.4) cmsg='4 = correlator name'
        else if (cgroup(1:4).eq.'FREQ') then
          if (ierr.eq.1) cmsg='1 = chan_def statements'
          if (ierr.eq.11) cmsg='11 = subgroup'
          if (ierr.eq.12) cmsg='12 = RF frequency'
          if (ierr.eq.13) cmsg='13 = net sideband'
          if (ierr.eq.14) cmsg='14 = channel bandwidth'
          if (ierr.eq.15) cmsg='15 = channel ref'
          if (ierr.eq.16) cmsg='16 = BBC ref'
          if (ierr.eq.17) cmsg='17 = phase cal (not implemented)'
          if (ierr.eq.18) cmsg='18 = switching'
          if (ierr.eq.2) cmsg='2 = bit density'
          if (ierr.eq.3) cmsg='3 = sample rate'
        else if (cgroup(1:11).eq.'S2_HEAD_POS') then
          if (ierr.eq.1) cmsg='1 = S2 group order'
          if (ierr.eq.11) cmsg='11 = group list'
        else if (cgroup(1:8).eq.'HEAD_POS') then
          if (ierr.eq.1) cmsg='1 = headstack_pos'
          if (ierr.eq.11) cmsg='11 = index number'
          if (ierr.eq.12) cmsg='12 = head positions'
          if (ierr.eq.2) cmsg='2 = pass_order'
          if (ierr.eq.21) cmsg='21 = index-subpass'
        else if (cgroup(1:2).eq.'IF') then
          if (ierr.eq.1) cmsg='1 = if_def statements'
          if (ierr.eq.11) cmsg='11 = IF ref'
          if (ierr.eq.12) cmsg='12 = IF input'
          if (ierr.eq.13) cmsg='13 = polarization'
          if (ierr.eq.14) cmsg='14 = LO frequency'
          if (ierr.eq.15) cmsg='15 = sideband'
          if (ierr.eq.16) cmsg='16 = phase cal (not implemented)'
        else if (cgroup(1:10).eq.'PROCEDURES') then
          if (ierr.eq.1) cmsg='1 = procedure name prefix'
        else if (cgroup(1:4).eq.'ROLL') then
          if (ierr.eq.1) cmsg='1 = roll on/off'
          if (ierr.eq.2) cmsg='2 = roll_def statements'
          if (ierr.eq.21) cmsg='21 = headstack'
          if (ierr.eq.22) cmsg='22 = home track'
          if (ierr.eq.23) cmsg='23 = track list'
        else if (cgroup(1:9).eq.'S2_TRACKS') then
          if (ierr.eq.1) cmsg='1 = S2 record mode'
          if (ierr.eq.2) cmsg='2 = S2 track frame format'
        else if (cgroup(1:6).eq.'TRACKS') then
          if (ierr.eq.1) cmsg='1 = track frame format'
          if (ierr.eq.2) cmsg='2 = fanout_def statements'
          if (ierr.eq.21) cmsg='21 = subpass'
          if (ierr.eq.22) cmsg='22 = chan ref'
          if (ierr.eq.23) cmsg='23 = sign/magnitude'
          if (ierr.eq.24) cmsg='24 = headstack number'
          if (ierr.eq.25) cmsg='25 = track list'
        else if (cgroup(1:4).eq.'SITE') then
          if (ierr.eq.1) cmsg='1 = site name'
          if (ierr.eq.2) cmsg='2 = side 2-letter ID'
          if (ierr.eq.3) cmsg='3 = xyz position'
          if (ierr.eq.4) cmsg='4 = occupation code'
          if (ierr.eq.5) cmsg='5 = horizon map az'
          if (ierr.eq.6) cmsg='6 = horizon map el'
        else if (cgroup(1:6).eq.'SOURCE') then
          if (ierr.eq.1) cmsg='1 = IAU name'
          if (ierr.eq.2) cmsg='2 = common name'
          if (ierr.eq.3) cmsg='3 = RA'
          if (ierr.eq.4) cmsg='4 = dec'
          if (ierr.eq.5) cmsg='5 = epoch'
        else if (cgroup(1:5).eq.'SCHED') then
          if (ierr.eq.1) cmsg='1 = station'
          if (ierr.eq.2) cmsg='2 = start date/time'
          if (ierr.eq.3) cmsg='3 = source name'
          if (ierr.eq.4) cmsg='4 = source index not found'
          if (ierr.eq.5) cmsg='5 = code index'
          if (ierr.eq.6) cmsg='6 = data start time'
          if (ierr.eq.7) cmsg='7 = data end time'
          if (ierr.eq.8) cmsg='8 = footage'
          if (ierr.eq.9) cmsg='9 = pass number'
          if (ierr.eq.10) cmsg='10 = pointing sector'
        endif ! group name
        write(luscn,9200) cmsg(1:trimlen(cmsg))
9200    format('ERRORMSG02 'a)
      endif ! non-zero ierr

      return
      end  

