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

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/skobs.ftni'
C
C Input:
      logical kskd
C Output:
      INTEGER   IERR
C Local:
      integer itearl_local
      INTEGER   IC,TRIMLEN
      integer idir,nline,ntapes,ncount,npage,maxline,iline,
     .ifeet,inewp,iyear,ix,ns,nsline,ns2,irh,irm,ns3,ns4,idd,
     .idm,ihd,imd,isd,id1,ih1,im1,is1,mjd,ival,id2,ih2,im2,is2,ids,
     .i,idur,nm,l,ifdur,id,ieq,irun,idr,ihr,imr,isr
      real rs,ds,val
      real speed_snap ! speed from SNAP file
      integer ichcm_ch,isecdif,julda ! function
      LOGICAL   KEX
      logical     kazel,kwrap,ksat
      character*128 cbuf,cbuf_in
      character*8 csor,cexper,cstn
      character*3 cdir,cnewtap,cday
      character*9 cti,c1,c2,c3
      character*2 cpassp,cpass,ch1,cm1,cs1
      character*1 cid,csgn
      character*7 cwrap
      logical kstart,ks2,krunning
      double precision xpos,ypos,zpos,rarad,dcrad,ut,az,el


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
C 3. Set up printer and write header lines

      write(luscn,9200) cinname(1:ic)
9200  format(' Printing summary of SNAP file ',a)

      call setprint(ierr,iwidth,0)
      if (ierr.ne.0) return
C
C 4. Loop over SNAP file records

      cexper=' '
      iyear = 0
      cstn = ' '
      cid = ' '
      kazel=.false.
      kwrap=.false.
      ksat=.false.
      kstart=.true.
      krunning=.false.
      csor=' '
      idir = 0
      nline = 0
      ntapes = 0
      ncount = 0
      npage = 0
      if (iwidth.eq.80) then
        maxline = 48
      else
        maxline = 50
      endif
      iline = maxline
      cday = '   '
      ifeet = 0
      inewp = 0
      cnewtap = 'XXX'
      if (kskd) then
        ks2=ichcm_ch(lstrec(1,istn),1,'S2').eq.0
      else ! read SNAP file
        ks2=.false.
        do while (.not.ks2)
          read(lu_infile,'(a)',err=990,end=440,iostat=IERR) cbuf_in
          call c2upper(cbuf_in,cbuf)
          if (index(cbuf,'DATA_VALID').ne.0) ks2=.true. 
        enddo
440     rewind(lu_infile)
      endif

      do while (.true.) ! read loop
        read(lu_infile,'(a)',err=990,end=990,iostat=IERR) cbuf_in
          call c2upper(cbuf_in,cbuf)
        nline = nline + 1

C 5.  Read first lines of SNAP file to get year, experiment name, station.
C     If we have a schedule file, station position is already in common,
C     otherwise read it from the header line. If the first line in the
C     SNAP file is a comment, then the header lines are probably there.
C     In all cases, rewind the file at the end so the following program 
C     loop reads all lines.

        if (nline.eq.1.and.cbuf(1:1).eq.'"') then !read first lines
            read(cbuf,9001) cexper,iyear,cstn,cid !header line
9001        format(2x,a8,2x,i4,1x,a8,2x,a1)
          if (.not.kskd) then !read station position from SNAP file header
            read(lu_infile,'(a)',err=990,end=990,iostat=IERR) cbuf_in !A line
                call c2upper(cbuf_in,cbuf)
                read(cbuf(2:),*) c1,c2,c3
                if (c3.eq.'AZEL'.or.c3.eq.'SEST'.or.c3.eq.'ALGO') then
                  kwrap=.true.
                else
                  kwrap=.false.
                endif
            read(lu_infile,'(a)',err=990,end=990,iostat=IERR) cbuf_in !P line
                call c2upper(cbuf_in,cbuf)
            if (trimlen(cbuf).lt.40) then ! not there
              write(luscn,9002)
9002          format(' SNAP file does not contain station position ',
     .        'data on line 3, therefore '/,
     .        ' az, el will not be calculated for this listing.')
              kazel = .false.
            else ! it's there
                  ix=index(cbuf(6:),' ')
              read(cbuf(6+ix:),*) xpos,ypos,zpos
              nline = 3
              kazel = .true.
            endif
          else !get from common (from schedule file)
            xpos = stnxyz(1,istn)
            ypos = stnxyz(2,istn)
            zpos = stnxyz(3,istn)
            kazel = .true.
                kwrap=.false.
                if (iaxis(istn).eq.3.or.iaxis(istn).eq.6.or.iaxis(istn)
     .          .eq.7) kwrap=.true.
          endif !kskd/not
            rewind(lu_infile)
            nline = 1
            read(lu_infile,'(a)',err=990,end=990,iostat=IERR) cbuf_in
            call c2upper(cbuf_in,cbuf)
            call initf(lu_infile,ierr)
        endif !read first lines

        if (cbuf(1:1).ne.'"') then !non-comment line
        if (index(cbuf,'SOURCE=').ne.0) then ! new scan starts here
          if (csor.ne.' ') then ! output a line
            if (npage.eq.0) then
              if (kskd) then ! get from common
                itearl_local=itearl(istn)
              else ! calculate local ITEARL here
                itearl_local = isd-is1
                if (itearl_local.lt.0) itearl_local=itearl_local+60
              endif
            endif
            call lstsumo(iline,npage,cstn,cid,cexper,maxline,
     .      idir,
     .      speed_snap,itearl_local,kwrap,ks2,cday,kazel,ksat,kstart,
     .      nsline,csor,cwrap,ch1,cm1,cs1,ih1,im1,is1,
     .      ihd,imd,isd,ih2,im2,is2,idm,ids,cpass,ifeet,cnewtap,cdir,
     .      kskd,ncount,ntapes,
     .      rarad,dcrad,xpos,ypos,zpos,mjd,ut)
C           Here is where we can determine early start without the schedule
          endif ! output a line
C       Now get the source info for the new scan 
          ns = index(cbuf,',')-1
          csor = cbuf(8:ns)
          kstart=.false.
          nsline = nline
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

        else if (index(cbuf,'READY').ne.0) then
          cnewtap = 'XXX'
          ifeet = 0

        else if (index(cbuf,'MIDTP').ne.0) then
          inewp = 1
          if (idir.eq.1) inewp = 0
          if (inewp.eq.1) ifeet = 0

        else if (index(cbuf,'MIDOB').ne.0) then ! data start time
          read(cti,'(i3,3i2)') idd,ihd,imd,isd
          ut = ihd*3600.d0+imd*60.d0+isd  ! UT in seconds
          mjd = julda(1,idd,iyear-1900)
C         Update footage with running time since last update
          irun = isecdif(idd,ihd,imd,isd,idr,ihr,imr,isr)
          if (ks2) ifeet = ifeet + irun ! seconds
C         Reset running time 
          idr=idd
          ihr=ihd
          imr=imd
          isr=isd

        else if (index(cbuf,'!').ne.0) then
          if (cbuf(2:2).ge.'0'.and.cbuf(2:2).le.'9') then ! valid day
          cti = cbuf(2:10)
          if (cti(1:3).ne.cday) then
            cday = cti(1:3)
            if (npage.gt.0) then
              write(luprt,9320) cday
9320          format('  Day ',a)
              iline=iline+1
            endif
          endif
          endif ! valid day

        else if (index(cbuf(1:2),'ST').ne.0) then ! tape start time
          ch1=cti(4:5)
          cm1=cti(6:7)
          cs1=cti(8:9)
          read(cti,'(i3,3i2)') id1,ih1,im1,is1
C         Update running time if this is a true start
          if (.not.krunning) then
            idr=id1
            ihr=ih1
            imr=im1
            isr=is1
          endif
          krunning = .true. ! tape has started
C         speed may be a string (example: slp), 
C                        integer (example: 80, 135), 
C                     or real (example: 266.66)
          read(cbuf(8:),*,iostat=ierr) val
          if (ierr.eq.0) then ! valid speed
            speed_snap = val 
            ifeet = 10*ifix(float(ifeet/10)) ! nearest 10 feet
          endif
          idir = 1
          cdir = cbuf(4:6)
          if (cdir.eq.'REV') idir=-1

        else if (index(cbuf(1:2),'ET').ne.0.or.
     .           index(cbuf(1:6),'POSTOB').ne.0) then ! data stop time
          read(cti,'(i3,3i2)') id2,ih2,im2,is2
          if (index(cbuf(1:2),'ET').ne.0) then ! tape has stopped
            krunning = .false. 
            kstart=.true.
            idr=id2
            ihr=ih2
            imr=im2
            isr=is2
          endif
          idur = isecdif(id2,ih2,im2,is2,idd,ihd,imd,isd)
          idm = idur/60
          ids = idur - idm*60

        else if (index(cbuf,'FAST').ne.0) then !add spin feet
          nm = index(cbuf,'M')
          if (nm.gt.0) then
            read(cbuf(7:nm-1),*) ival
            idur = 60*ival
          else
            nm=6
            idur=0
          endif
          l=trimlen(cbuf)
          read(cbuf(nm+1:l-1),*) ival
          idur = idur + ival 
          ifdur = 160 + (idur-10)*(270.0/12.0) ! footage of fastf/r
          id=+1
          if (cbuf(5:5).eq.'R') id=-1
          if (inewp.eq.0.or.ifeet.gt.0) ifeet=ifeet+ifdur*id

        else if (index(cbuf,'CHECK').ne.0) then
          if (cnewtap.eq.'   ') cnewtap = ' * '

        else if (index(cbuf,'DATA_VALID=').ne.0) then ! skip over

        else if (index(cbuf,'=').ne.0) then !probably setup proc
          ieq = index(cbuf,'=')
          cpassp=cpass ! previous pass
          cpass = cbuf(ieq+1:ieq+2)
          if (ks2.and.cpass.ne.cpassp) ifeet=0 ! reset feet for new group

        endif
        endif !non-comment line
      enddo !read loop

990   continue
C     Output the final scan
      call lstsumo(iline,npage,cstn,cid,cexper,maxline,
     .      idir,
     .speed_snap,itearl_local,kwrap,ks2,cday,kazel,ksat,kstart,
     .nsline,csor,cwrap,ch1,cm1,cs1,ih1,im1,is1,
     .ihd,imd,isd,ih2,im2,is2,idm,ids,cpass,ifeet,cnewtap,cdir,
     .kskd,ncount,ntapes,
     .      rarad,dcrad,xpos,ypos,zpos,mjd,ut)
      write(luprt,'(/" Total number of observations: ",i5/
     .               " Total number of tapes: ",i3)') ncount, ntapes

      call luff(luprt)
      close(luprt)
      call prtmp

      RETURN
      end
