      SUBROUTINE LSTSUM(kskd,IERR)

C Create SUMMARY of SNAP file
C
C NRV 901121 New routine, modeled on CLIST.BAS
C            NOTE: this gets pass numbers right only for 'SX' experiments
C NRV 901205 Removed output file, going directly to printer
C NRV 910703 Add PRTMP call at end
C NRV 910825 Change check for setup procedure to end, remove check
C            for "SX" and replace with check for '='. All other commands
C            have already been checked and processed. This is the only
C            procedure which has the '=' sign.
C nrv 930412 implicit none
C nrv 930430 Fix output for low density stations
C nrv 940114 Calculate ITEARL if we don't have a schedule file
c nrv 940131 Read cable wrap from SOURCE line and write to output
C nrv 940201 Write wrap only for azel mounts
C nrv 940609 Fix output for SOURCE=AZEL for satellites
C nrv 940610 Fix it again to avoid the trailing "D" on az,el
C 960126 nrv Remove "9/8" multiplication on speed because SNAP files
C            now use the actual speeds.
C 960201 nrv Change input buffer to upper case before processing.
C 960810 nrv Change ITEARL to itearl_local
C 960819 nrv Changes for S2, non-numeric speed in ST command. Keep track
C            of footage if tapes are run continuously. Rearrange sections
C            so that a new SOURCE= command triggers output of previous
C            scan. Determine if this is an S2 SNAP file by reading it to
C            find a "data_valid" line.  "feet" is running time in seconds
C            for S2, footage in feet for other recorders.
C 960913 nrv Change logic for accumulating S2 running time and determining
C            whether tape has truly started. 
C 960917 nrv If we come to end of file, output what's left at that point.
C 960920 nrv Remove line output to new routine LSTSUMO.
C 961105 nrv Check for READY instead of UNLOD so that the final scan
C            is correctly output.
C 961108 nrv Undo the final FASTR to spin down the tape so the last
C            footage is correct.
C 970131 nrv Put updating of IFEET back in here, after call to LSTSUMO.
C 970131 nrv Remove some checks for KS2 and replace with others.
C 970207 nrv Allow default orientation or force.
C 970214 nrv change id to 2 letters
C 970304 nrv Add COPTION for defaults
C 970312 nrv Add call to READ_SNAP1 to read first line in freefield
C 970313 nrv Compute itearl_local with full d/h/m/s instead of just seconds
C 970313 nrv Revise footage counts to correctly handle adaptive early start.
C 970321 nrv For continuous motion use "data comments.
C 970401 nrv Save variables for LSTSUMO and print them after the next
C            midob is found, so that we know if there was an ET.
C 970401 nrv Add itlate_local to LSTSUMO call.
C 970728 nrv Set ifeet_print=ifeet if ifeet_print=-1 when the previous 
C            output line is printed, because this means no ST or data_start
C            have occurred for a non-tape scan. Don't update the footage
C            on "data stop" if the tape is not running.
C 970730 nrv Don't set ifeet=0 at midtp because it might not be.
C 970801 nrv For non-tape scans set cnewtap='@  '
C 971003 nrv This is not fixed: If the last scan has late stop, the
C            listing shows the tape stop time and the data stop time
C            to be the same. 
C 971210 nrv Check "data_valid" commands instead of "data start/stop".
C 971210 nrv Guess it's an S2 .snp file if you find "st=for,slp".
C 980911 nrv Add a format string for the time field. Decide if it's
C            a new time by whether there's punctuation.
C 980914 nrv Print out the full date for each new day. Add IYEAR to
C            LSTSUMO call. Handle both new and old style SNAP dates.
C 980916 nrv Remove decoding time field to a subroutine TIMIN.
C 980917 nrv Recognize either "data_valid" command or "data xx" comment.
C 990115 nrv Recognize ST=RECORD in SNAP file as a K4 command.
C 990117 nrv Calculate K4 footage using K4 speeds
C 990304 nrv Use sample rate not bandwidth because all stations
C            may not be using all the channels.
C 990305 nrv Call WRDAY instead of WRDATE.
C 991102 nrv Recognize the dual recorder commands. Remove the code
C            to a subroutine for getting information from common 
C            or directly from the .snp file. 
C 991103 nrv Add crack,creca,crecb to lstsumo call for headers, and
C            to lstsum_info call.
C 991108 nrv Parse FAST command timing by finding the '='.
C 991115 nrv Change 'XXX' to 'AAA' or 'BBB'. To 'Rec1' or 'Rec2'
C 000107 nrv Reduce maxline by 5, because there are more header lines.
C 000529 nrv Read scan name from SNAP file.
C 000601 nrv If ctimin doesn't return a valid format statement then
C            don't try to read the time.
C 000606 nrv SCAN_NAME command starts the new scan, not SOURCE=.
C 000611 nrv Add KSCAN to call.
C 000622 nrv Don't try to decode a time command without a valid format.
C 000614 nrv Save the line number of the SCAN_NAME command, not SOURCE.
C 001114 nrv Don't upper-case SCAN_NAME command.
C 020531 nrv Don't reset footage to zero at the start of the next
C            forward pass. The schedule doesn't always return the tape
C            to zero footage but may leave it positioned to start the
C            next pass at that point.
C 021014 nrv If the footage is not reset to zero at the start of the next
C            pass, then slight errors in timing/footage calculations may 
C            accumulate and result in erroneous printed footages. If there 
C            is a FASTR after the MIDTP, consider it a signal from the
C            schedule and reset to zero.
C 021014 nrv Read new FAST commands from the .snp file with fractional seconds.

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
C
C Input:
      logical kskd
C Output:
      INTEGER   IERR
C Local:
      integer iwid,itlate_local,itearl_local
      INTEGER   IC,TRIMLEN
      integer idir,nline,ntapes,ncount,npage,maxline,iline,
     .ifeet,inewp,iyear,ns,nsline,ns2,irh,irm,ns3,ns4,idd,
     .idm,ihd,imd,isd,id1,ih1,im1,is1,mjd,ival,id2,ih2,im2,is2,
     .idur,ne,nm,l,ifdur,id,ieq,irun,idr,ihr,imr,isr,ifdur_save,
     .ifeet_print,idt,iht,imt,ist,idurm,idurs,ift,idif,ix
      real rs,ds,val,rifdur
      real speed_snap ! speed from SNAP file
      double precision speed_k4 ! speed for K4
      double precision conv_k4 ! speed scaling for feet-->counts
      integer isecdif,julda ! function
      LOGICAL   KEX
      logical     kazel,kwrap,ksat,kmidtp
      character*128 cbuf,cbuf_in
      character*8 csor,cexper,cstn
      character*3 cdir,cday_prev
      integer iday
      character*20 cti
      character*2 cid,cpassp,cpass,ch1,cm1,cs1,ch3,cm3,cs3
      character*1 cid1,cs,csgn
      character*7 cwrap
      logical kgot,kend,kstart,kk4,ks2,krunning
      double precision xpos,ypos,zpos,rarad,dcrad,ut,az,el
      integer nsline_s,ihd_s,imd_s,isd_s,
     .ih2_s,im2_s,is2_s,idurm_s,idurs_s,ifeet_print_s,mjd_s
      double precision rarad_s,dcrad_s,ut_s
      character*3 cdir_s,cday_save,cday_sor
      character*4 cnewtap,cnewtap_s
      character*12 cscan,cscan_s
      character*2 cpass_s,ch1_s,cm1_s,cs1_s
      logical kstart_s,kmotion,kmotion_s,kscan
      character*8 csor_s
      character*7 cwrap_s
      character*20 ctiformat,cctiformat
      character*3 cd1,cd3
      character*8 crack,creca,crecb

C 1.0  Check existence of SNAP file.

      IC = TRIMLEN(CINNAME)
      INQUIRE(FILE=CINNAME,EXIST=KEX)
      IF (.NOT.KEX) THEN
        WRITE(LUSCN,9398) CINNAME(1:IC)
9398    FORMAT(' LSTSUM01 - SNAP FILE ',A,' DOES NOT EXIST')
       RETURN
      ENDIF
      OPEN(LU_INFILE,FILE=CINNAME,STATUS='OLD',IOSTAT=IERR)
C
      IF(IERR.EQ.0) THEN
        REWIND(LU_INFILE)
        CALL INITF(LU_INFILE,IERR)
      ELSE
        WRITE(LUSCN,9400) IERR,CINNAME(1:IC)
9400    FORMAT(' LSTSUM02 - ERROR ',I3,' OPENING SNAP FILE ',A)
        RETURN
      ENDIF
C
C 2. Set up printer and write header lines

      write(luscn,9200) cinname(1:ic)
9200  format(' Printing summary of SNAP file ',a)

      cs = csize
      if (cs.eq.'D') cs=coption(3)(2:2) ! use default
      iwid = iwidth
      if (iwid.eq.-1) then ! use default
        if (coption(3)(1:1).eq.'P') iwid=80
        if (coption(3)(1:1).eq.'L') iwid=137
      endif
      if (iwid.eq.-1.or.iwid.eq.80) then !default is portrait
        if (cs.eq.'S') then ! small
          call setprint(ierr,2)
          maxline = 55
        else ! large
          maxline = 40
          call setprint(ierr,0)
        endif
      else if (iwid.eq.137) then ! landscape
        if (cs.eq.'S') then ! small
          maxline = 38
          call setprint(ierr,3)
        else ! large
          maxline = 25
          call setprint(ierr,1)
        endif
      endif
        
      if (ierr.ne.0) then
        write(luscn,'("LSTSUM03 - Error ",i5," setting up printer.")')
     .  ierr
        return
      endif
C
C 3. Initialize local variables 

      cexper=' '
      iyear = 0
      kgot=.false.
      cstn = ' '
      cid = '  '
      kazel=.false.
      kwrap=.false.
      ksat=.false.
      kstart=.true.
      kmidtp=.false.
      kend=.false.
      krunning=.false.
      kmotion=.false.
      csor=' '
      cday_sor=' '
      idir = 0
      speed_snap=0
      iline = maxline
      ifdur_save=0
      ntapes = 0
      ncount = 0
      npage = 0
      cday_save = ' '
      cday_prev = ' '
      idur=-1
      ift=-1
      ifeet = 0
      ifeet_print=-1 ! set as a flag
      inewp = 0
      cnewtap = '    '
      cscan = '     '
      cscan_s = '     '

C 4. Set other variables by reading the .snp file or getting
C    information from common.

      call lstsum_info(kskd,cexper,iyear,cstn,cid1,cid,
     .xpos,ypos,zpos,kazel,kwrap,kk4,ks2,
     .crack,creca,crecb,ierr,kscan)
C 
C Calculate K4 scaling.
      if (kk4) then ! K4 speed 
C         K4 scaling factor is 55 cpd/11.25 fps if the schedule
C         was produced using sked with Mk/VLBA footage calculations
C         and no fan-out or fan-in. Footages were therefore already
C         scaled by bandwidth calculations in sked.
        conv_k4 = 55.389387393d0 ! counts/sec 
        speed_k4 = conv_k4*samprate(1)/4.0d0 ! 55, 110, or 220 cps
        ifeet = 54
      endif

C 5. Main loop to read .snp file and print summary of observations.

441   rewind(lu_infile)
      nline=0
      do while (.true.) ! read loop
        read(lu_infile,'(a)',err=991,end=990,iostat=IERR) cbuf_in
        if (index(cbuf_in,'scan_name=').eq.0) then 
          call c2upper(cbuf_in,cbuf) ! upper-case the input
        else
          cbuf = cbuf_in
        endif
        nline = nline + 1
C       if (cbuf(1:1).ne.'"') then !non-comment line
        if (index(cbuf,'scan_name=').ne.0.or.
     .    index(cbuf,'SOURCE=').ne.0) then ! new scan starts here
          if (index(cbuf,'scan_name=').ne.0) then ! scan name
            cscan_s = cscan
            ix = index(cbuf,'=')
            read(cbuf(ix+1:),'(a)') cscan
            nsline_s = nsline
            nsline = nline 
          else if (index(cbuf,'SOURCE=').ne.0) then ! source name
            if (csor.ne.' ') then ! output a line
            if (npage.eq.0) then
C           Here is where we determine early start without the schedule
              if (kskd) then ! get from common
                itearl_local=itearl(istn)
                itlate_local=itlate(istn)
              else ! calculate local ITEARL here
                itearl_local = isecdif(idd,ihd,imd,isd,id1,ih1,im1,is1)
                if (itearl_local.lt.0) 
     .          itearl_local = isecdif(id1,ih1,im1,is1,idd,ihd,imd,isd)
                itlate_local=0 ! figure this out later
              endif
            endif
            kgot=.true.
            cday_save=cday_sor
            kstart_s=kstart
C           nsline_s=nsline
            csor_s=csor
            cwrap_s=cwrap
            ch1_s=ch1
            cm1_s=cm1
            cs1_s=cs1
            ihd_s=ihd
            imd_s=imd 
            isd_s=isd
            ih2_s=ih2
            im2_s=im2
            is2_s=is2
            idurm_s=idurm
            idurs_s=idurs
            cpass_s=cpass
            ifeet_print_s=ifeet_print
            cnewtap_s=cnewtap
            kmotion_s=kmotion
            cdir_s=cdir
            rarad_s=rarad
            dcrad_s=dcrad
            mjd_s=mjd
            ut_s=ut
            ifdur_save=0
            ifeet_print=-1 ! set as a flag
            idur=-1
            ift=-1
            cnewtap = '    '
            kmotion=.false.
          endif ! output a line
C       Now get the source info for the new scan 
          ns = index(cbuf,',')-1
          csor = cbuf(8:ns)
          cday_sor = ' '
C         nsline = nline ! moved to scan command
          kstart=.false.
C         kend=.false.
          ns2 = ns+2+index(cbuf(ns+2:),',')-2
          if (csor.ne.'AZEL') then ! celestial source
            ksat=.false.
            read(cbuf(ns+2:ns2),9101) irh,irm,rs
9101        format(i2,i2,f4.1)
            rarad = (irh+irm/60.d0+rs/3600.d0)*PI/12.d0
            ns3 = ns2+2+index(cbuf(ns2+2:),',')-1
            read(cbuf(ns2+2:ns2+2),'(a1)') csgn
            if (csgn.eq.'-'.or.csgn.eq.'+') ns2=ns2+1
            read(cbuf(ns2+2:ns3),9102) idd,idm,ds
9102        format(i2,i2,f4.1)
            dcrad = (idd+idm/60.d0+ds/3600.d0)*PI/180.d0
            if (csgn.eq.'-') dcrad=-dcrad
            ns4 = ns3+index(cbuf(ns3+2:),',')
            if (ns4.gt.ns3) then
              read(cbuf(ns4+2:),'(a)') cwrap
            else
              cwrap=' '
            endif
          else ! satellite AZEL
            ns2 = ns+2+index(cbuf(ns+2:),'D')-2
            read(cbuf(ns+2:ns2),*) az
            ns3 = ns2+2+index(cbuf(ns2+2:),'D')-2
            read(cbuf(ns2+3:ns3),*) el
            ksat = .true.
          endif
          endif ! scan or source name

        else if (index(cbuf,'READY').ne.0) then
          cnewtap = 'XXX '
          if (index(cbuf,'READY1').ne.0) then ! rec 1
            cnewtap = 'Rec1'
          elseif (index(cbuf,'READY2').ne.0) then ! rec 2
            cnewtap = 'Rec2'
          endif
          ifeet = 0
          if (kk4) ifeet = 54

        else if (index(cbuf,'MIDTP').ne.0) then
          inewp = 1
          idur=-1 ! reset duration so it gets calculated again
C Don't reset footage to zero for a new forward pass. This probably 
C fixed C an earlier problem, but it's not the right thing to do. 
C The schedule might have left the footage at the place where the
C tape stopped on the previous pass.
C         if (idir.eq.1) inewp = 0
C         if (inewp.eq.1) ifeet = 0
C Instead, reset the footage if a FASTR is found after midtp.
          kmidtp=.true.
          if (ifeet.lt.0) ifeet=0

        else if (index(cbuf,'MIDOB').ne.0) then ! data start time
          read(cti,ctiformat) idd,ihd,imd,isd
          ut = ihd*3600.d0+imd*60.d0+isd  ! UT in seconds
          mjd = julda(1,idd,iyear-1900)
          if (krunning) then ! Update footage since last time
            irun = isecdif(idd,ihd,imd,isd,idr,ihr,imr,isr)
            if (ks2) then
              ifeet = ifeet + irun ! seconds
            else if (kk4) then
              ifeet = ifeet + irun*speed_k4 ! counts
            else
              ifeet = ifeet + irun*idir*(speed_snap/12.0) ! feet
            endif
          endif
C         Reset running time  
          idr=idd
          ihr=ihd
          imr=imd
          isr=isd
C        Now print the line because we would have found the ET by now.
          if (kgot) then ! got the _s variables set
            if (cday_save.ne.cday_prev.and.cday_prev.ne.' ') then
              read(cday_save,'(i3)') iday
              call wrday(luprt,iyear,iday)
              iline=iline+1
            endif
            cday_prev = cday_save
            if (cnewtap_s.eq.'    '.and..not.kmotion_s) cnewtap_s='@   '
            if (ifeet_print_s.eq.-1) ifeet_print_s=0
            call lstsumo(iline,npage,cstn,cid,cexper,maxline,
     .      itearl_local,itlate_local,kwrap,kk4,ks2,cday_save,kazel,
     .      ksat,
     .      kstart_s,kend,nsline_s,csor_s,cwrap_s,ch1_s,cm1_s,cs1_s,
     .      ihd_s,imd_s,isd_s,ih2_s,im2_s,is2_s,ch3,cm3,cs3,
     .      idurm_s,idurs_s,cpass_s,ifeet_print_s,
     .      cnewtap_s,cdir_s,kskd,ncount,ntapes,
     .      rarad_s,dcrad_s,xpos,ypos,zpos,mjd_s,ut_s,iyear,
     .      crack,creca,crecb,cscan_s)
            kend=.false.
            if (ifeet_print.eq.-1) ifeet_print=ifeet
          endif

        else if (index(cbuf,'!').ne.0) then ! time 
          call timin(cbuf,cti,ctiformat,cctiformat,iyear)
          if (ctiformat(1:1).eq.'(') then ! valid format
            if (cday_sor.eq.' ') read(cti,cctiformat) cday_sor
          else ! don't read it
          endif ! valid/don't

        else if (index(cbuf(1:2),'ST').ne.0.or.
     .           index(cbuf(1:11),'"DATA START').ne.0.or.
     .           index(cbuf(1:13),'DATA_VALID=ON').ne.0.or.
     .           index(cbuf(1:14),'DATA_VALID1=ON').ne.0.or.
     .           index(cbuf(1:14),'DATA_VALID2=ON').ne.0) then ! tape start time
          kmotion=.true.
          idur=-1 ! make sure we calculate duration from this point
          if (.not.krunning) then ! this is a true start
            krunning = .true. ! tape has started
            read(cti,cctiformat) cd1,ch1,cm1,cs1
C           ch1=cti(4:5)
C           cm1=cti(6:7)
C           cs1=cti(8:9)
            read(cti,ctiformat) id1,ih1,im1,is1
            kstart=.true.
C           Restart the running time clock
            idr=id1
            ihr=ih1
            imr=im1
            isr=is1
            if (index(cbuf(1:2),'ST').ne.0) then ! get speed and direction
C             speed may be a string (example: st=for,slp), 
C                           integer (example: st=rev,80), 
C                           or real (example: st=for,266.66)
C             Command may be st, st1, st2.
              nm = index(cbuf,',') ! find the ,
              read(cbuf(nm+1:),*,iostat=ierr) val
              if (ierr.eq.0) then ! valid speed
                speed_snap = val 
C               ifeet = 10*ifix(float(ifeet/10)) ! nearest 10 feet
C               Do this round off just before printing, in lstsumo
C             else ! may be S2 speed
              endif
              idir = 1
              nm = index(cbuf,'=') ! find the =
              cdir = cbuf(nm+1:nm+3) ! really should parse this
              if (cdir.eq.'REV') idir=-1
            endif ! get speed and direction
          else ! update footage 
            read(cti,ctiformat) idt,iht,imt,ist
            idif = isecdif(idt,iht,imt,ist,idr,ihr,imr,isr)
            if (ks2) then
              ifeet = ifeet + idif ! seconds
            else if (kk4) then
              ifeet = ifeet + idif*speed_k4 ! counts
            else
              ifeet = ifeet + idif*idir*(speed_snap/12.0) ! feet
            endif
C           Restart the running time clock
            idr=idt
            ihr=iht
            imr=imt
            isr=ist
          endif
          if (ifeet_print.eq.-1) ifeet_print=ifeet ! save it for printing

        else if (index(cbuf(1:2),'ET').ne.0) then
          krunning = .false. 
          kend=.true.
          read(cti,ctiformat) id2,ih2,im2,is2
          read(cti,cctiformat) cd3,ch3,cm3,cs3
C         ch3=cti(4:5)
C         cm3=cti(6:7)
C         cs3=cti(8:9)
C         If a "data stop" already occurred for this scan, don't make
C         a new duration.
          if (idur.eq.-1) then ! no dur yet this scan
            idur = isecdif(id2,ih2,im2,is2,idr,ihr,imr,isr)
            idurm = idur/60
            idurs = idur - idurm*60
C           Update running time
            idr=id2
            ihr=ih2
            imr=im2
            isr=is2
C           Update footage with timing
            if (ks2) then
              ifeet = ifeet + idur ! seconds
            else if (kk4) then
              ifeet = ifeet + idur*speed_k4
            else
              ifeet = ifeet + idur*idir*(speed_snap/12.0) ! feet
            endif
C         idir=0
C         Set direction to 0 now that we are stopped. It will take
C         an "st" command to reset this
          endif ! no dur yet this scan

        else if (index(cbuf(1:15),'DATA_VALIDA=OFF').ne.0  .or.
     .           index(cbuf(1:15),'DATA_VALIDB=OFF').ne.0  .or.
     .           index(cbuf(1:10),'"DATA STOP').ne.0.or.
     .           index(cbuf(1:6),'POSTOB').ne.0) then ! data stop time
          read(cti,ctiformat) id2,ih2,im2,is2
          if (idur.eq.-1) then ! no stop yet
            idur = isecdif(id2,ih2,im2,is2,idr,ihr,imr,isr)
            idurm = idur/60
            idurs = idur - idurm*60
C           Update running time
            idr=id2
            ihr=ih2
            imr=im2
            isr=is2
C           Update footage with timing
C Only update footage if tape is still running. It will have been already
C updated at the 'et' if it's now stopped. If there was not 'et' then
C this is either continuous tape motion (needs updating) or else
C non-tape and not running (no updating).
            if (ks2) then
              ifeet = ifeet + idur ! seconds
            else if (krunning) then
              if (kk4) then
                ifeet = ifeet + idur*speed_k4 ! feet
              else
                ifeet = ifeet + idur*idir*(speed_snap/12.0) ! feet
              endif
            endif
          endif ! no stop yet

        else if (index(cbuf,'FAST').ne.0) then !add spin feet
C         examples: fastf=3m42.34s   fastr=2.35m   fastf=34.56s
          ne = index(cbuf,'=')
          nm = index(cbuf,'M')
          if (nm.gt.0) then ! "M" found
            read(cbuf(ne+1:nm-1),*) val
            ifdur = ifix(60.0*val)
          else 
            nm=ne
            ifdur=0
          endif ! "M" found
          l=trimlen(cbuf)
          read(cbuf(nm+1:l-1),*) val
          rifdur = ifdur + val ! seconds of time for spin
          ifdur = ifix(160.0 + (rifdur-10.0)*(270.0/12.0)) ! footage of fastf/r
          id=+1
          if (cbuf(5:5).eq.'R') id=-1
C Why only update the footage if it's a new pass ? The FASTF could occur
C anywhere in the pass.
C         if (inewp.eq.0.or.ifeet.gt.0) ifeet=ifeet+ifdur*id
          if (              ifeet.gt.0) ifeet=ifeet+ifdur*id
          if (ifeet.lt.0) ifeet=0
          ifdur_save = ifdur*id ! save in case we have to undo it
C If there was a recent MIDTP then assume that this FASTR is meant to return 
C the footage to zero to start the new forward pass.
          if (id.eq.-1) then ! this was FASTR
            if (kmidtp) ifeet = 0 
          endif ! this was FASTR
          kmidtp=.false.

        else if (index(cbuf,'CHECK').ne.0) then
          if (cnewtap.eq.'    ') cnewtap = ' *  '

        else if (index(cbuf,'=').ne.0) then !might be setup proc
          if (index(cbuf,'DATA_VALID').eq.0.and.
     .        index(cbuf,'ST1=').eq.0.and.index(cbuf,'ST2=').eq.0) then ! setup
            ieq = index(cbuf,'=')
            cpassp=cpass ! previous pass
            cpass = '  '
            cpass = cbuf(ieq+1:ieq+2)
            if (cpass(2:2).eq.' ') then ! shift right
              cpass(2:2)=cpass(1:1)
              cpass(1:1)=' '
            endif ! shift right
            if (ks2.and.cpass.ne.cpassp) ifeet=0 ! reset feet for new group
          endif ! setup
        endif ! might be setup proc
      enddo !read loop

990   continue
      ierr=0
C     Output the final scan
      if (ifdur_save.ne.0) ifeet=ifeet-ifdur_save ! undo the final fastr
      if (cnewtap.eq.'    '.and..not.kmotion) cnewtap='@   '
      if (cday_sor.ne.cday_prev.and.cday_prev.ne.' ') then
        read(cday_save,'(i3)') iday
        call wrdate(luprt,iyear,iday)
        iline=iline+1
      endif
      if (cscan.ne.'     ') cscan_s = cscan
      call lstsumo(iline,npage,cstn,cid,cexper,maxline,
     .itearl_local,itlate_local,kwrap,kk4,ks2,cday_sor,kazel,ksat,
     .kstart,kend,nsline,csor,cwrap,ch1,cm1,cs1,
     .ihd,imd,isd,ih2,im2,is2,
     .ch3,cm3,cs3,
     .idurm,idurs,cpass,ifeet_print,
     .cnewtap,cdir,
     .kskd,ncount,ntapes,
     .      rarad,dcrad,xpos,ypos,zpos,mjd,ut,iyear,
     .      crack,creca,crecb,cscan_s)
      write(luprt,'(/" Total number of scans: ",i5/
     .               " Total number of tapes: ",i3)') ncount, ntapes

      call luff(luprt)
      close(luprt)
      if (iwid.eq.-1.or.iwid.eq.80) then
        call prtmp(0)
      else if (iwid.eq.137) then
        call prtmp(1)
      endif

991   if (ierr.ne.0) then
         write(luscn,9900) ierr
9900     format('LSTSUM04 - Error ',i5,' reading SNAP file.')
        return
      endif

      RETURN
      end
