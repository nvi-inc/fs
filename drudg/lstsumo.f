      subroutine lstsumo(kskd,itearl_local,itlate_local,maxline,
     >   iline,npage,num_scans,ntapes,             !These are modified by this routine
     >   nsline,
     >   itime_start,itime_end,itime_tape_start,itime_tape_stop,
     >   iDur,counter,cpass,cnewtap,cdir,cscan,cbuf_source)

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/freqs.ftni'
      include 'lstsum.ftni'
      include 'hardware.ftni'

C Writes an output line for LSTSUM.
C 960917 nrv New. Removed lines from LSTSUM to make this routine.
C 970131 nrv Remove updating of IFEET and put it back into LSTSUM.
C 970131 nrv Add KET to call. Change tape start into a string.
C 970306 nrv Change S2 to print minutes, not seconds. Add ".and..not.ks2" 
C            to the first two tests for output.
C 970321 nrv Remove KET from call.
C 970401 nrv Remove other extras from call. 
C 970401 nrv Change output to include Tape Stop column for 
C            continuous/late stop schedules.
C 970401 nrv Adaptive output. Don't include tape start or tape stop if
C            no early start or late stop.
C 970401 nrv Add itlate_local to call.
C 970728 nrv Add more explanatory header lines for the last column
C 970728 nrv If no tape motion, print "--" in pass field.
C 970812 nrv Print ifeet to nearest 20 feet (=1 sec at fast speed)
C 971210 nrv Print ifeet to nearest 1 min for S2. Change some headers.
C 980914 nrv Print full date. Add IYEAR to call.
C 990117 nrv Add KK4 to call. Add S2 or K4 to header. Change output
C            for K4 types.
C 991103 nrv Add crack,creca,crecb to call and print in header.
C 991115 nrv If ifeet=-1 then there's no scan to print.
C 000107 nrv If tape_motion_type is null, don't write it.
C 000529 nrv Add scan name.
C 021011 nrv Another digit for printing gap time.
! 122302 JMG Output tape type in header, also procedure names.

! Functions
      integer julda
      integer trimlen
      character lower
      logical ktimedif

C Input
      logical kskd
      integer itlate_local              !late stop
      integer itearl_local              !early start
      integer maxline                   !# of lines to output.

      integer iline,npage,num_scans,ntapes !modified in this routine!!!!!!!!!!
      integer nsline                    !snap line that scan starts.
      integer itime_start(5)            !start
      integer itime_end(5)              !end
      integer itime_tape_start(5)       !tape starting time
      integer itime_tape_stop(5)        !tape ending time.
      integer iDur		        !duration in min, seconds
      real    counter                   !tape/disc counter

      character*3 cdir                  !direction
      character*6 cnewtap
      character*9 cscan
      character*2 cpass
      character*128 cbuf_source         !contains source info.

C Output
C These are modified on return: iline, page,num_scans,ntapes

! Local
! Parsed for cbuf_source
      character*8 csor
      double precision rarad,dcrad
      character*7 cwrap
      double precision az,el

      integer idurm,idurs              !duration in minutes,seconds.
      character*1 csgn
      integer imin, ideg
      real sec
      integer irh,irm
      integer ns,ns2,ns3,ns4

C Local
      integer i,il,iaz,iel,ifeet_print
      logical kcont,kearl
      character*128 cbuf
!
! Saved local variables.
      integer iday_old
      save iday_old
      integer itime_tape_stop_old(5)
      integer itime_tape_start_old(5)
      save itime_tape_stop_old,itime_tape_start_old

      integer mjd                       !MJD of scan.
      double precision ut               !UT of scan

! Used to output proc names
      integer icode,ipass
      integer*2 lnamep(6)
      character*12 cnamep
      equivalence (lnamep,cnamep)

      integer*2 lcodeTmp
      character*2 ccodetmp
      equivalence (ccodetmp,lcodetmp)
      integer nch
      integer itype
      integer num_sub_pass
      character*12 lfilnam
! tape type
      character*6 cTapeType     !THICK,THIN SHORT
      character*4 cTapeDens     !HIGH, LOW

! Initialize
      if(npage .eq. 0 .and. iline .eq. maxline) then
        do i=1,5
         itime_tape_start_old(i)=0
         itime_tape_stop_old(i)=0
        end do
      endif

      kmv=.not.(ks2.or.kk4 .or. km5.or.km5p) ! kmv=Mk3/4 or VLBA
      kcont=.true. ! if we don't know, include the column
      if (kskd) kcont=tape_motion_type(istn).eq.'CONTINUOUS'.or.
     >                tape_motion_type(istn).eq.'ADAPTIVE'  .or.
     >                itlate(istn).gt.0
      kearl=itearl_local.gt.0

C  1. Headers.
      if (iline.ge.maxline) then ! new page, write header
        if (npage.gt.0) call luff(luprt)
        npage = npage + 1
        call strip_path(cinname,lfilnam)

        write(luprt,9200) lfilnam,npage
9200      format(' Schedule file: ',2x,a12,50x,'Page ',i3)
        if (kskd) then
          write(luprt,9201) cstnna(istn),lpocod(istn),
     .    lstcod(istn),(lexper(i),i=1,4)
9201      format(' Station:    ',5x,a8,' (',a2,') (',a1,')',4x,
     .           ' Session:    ',5x,4a2)
        else
          write(luprt,9203) cstn,cid,cexper
9203      format(' Station: ',9x,a8,' (',a2,')', 7x,'Session:    ',a8)
        endif

        if(kskd) then
          i=trimlen(tape_motion_type(istn))
          if(i .ne. 0) then
            if(tape_motion_type(istn) .eq. "ADAPTIVE") then
              write(luprt,9204) itgap(istn)
9204          format(" Tape motion:     ADAPTIVE (gap=",i3,")",3x,$)
            else
              write(luprt,9205) tape_motion_type(istn)(1:10)
9205          format(" Tape motion:     ",a,11x,$)
            endif
          endif

          if (ks2) then
            write(luprt,  '(" Recorder type:   S2")')
          else if (kk4) then
            write(luprt,  '(" Recorder type:   K4")')
          else if(km5 .or. km5p) then
            write(luprt,  '(" Recorder type:   DISK")')
          else if(.not. (km5 .or. km5p)) then
            if (bitdens(istn,1).gt.56000.0) then
               cTapeDens='High'
            else
               cTapeDens='Low'
            endif
            if(maxtap(istn) .lt. 5000) then
               cTapeType="Short"
            else if(maxtap(istn) .lt. 10000) then
               cTapeType="Thick"
            else
               cTapeType="Thin"
            endif
            write(luprt,'(" Tape type:       ",a6,2x,a4)')
     >           cTapeType,cTapeDens
          endif
        endif

        write(luprt,9210)  crack
9210    format(" Rack:            ",a)
        write(luprt, 9211)    creca,itearl_local
9211    format(" Recorder 1:      ",a,14x,"Early start: ",i6,1x,"sec")
        write(luprt, 9212)    crecb,itlate_local
9212    format(" Recorder 2:      ",a,14x,"Late  stop:  ",i6,1x,"sec")

! Put out procedure names
        if (km5.or. km5p .or.ks2.or.kk4) then ! setup proc names
          itype=1
        else
          itype=2
        endif
        do icode=1,ncodes
          num_sub_pass=npassf(istn,icode)
          if(num_sub_pass .ge. 1) then
            if(km5)  num_sub_pass=1
            write(luprt, '(" Mode",i2," Setup proc(s): ",$)') icode
            do ipass=1,num_sub_pass
              cnamep=" "
              call setup_name(itype,icode,ipass,lnamep,nch)
              call c2lower(cnamep,cnamep)
              write(luprt,'(a,1x,$)') cnamep
            end do
            lcodeTmp=lcode(icode)
            call c2lower(ccodetmp,ccodetmp)
            write(luprt,'(1x,"IFD proc: ifd",a2)') ccodetmp
          endif
        end do
! End of put out procedure names.

        write(luprt,'()')
        write(luprt,'(a)')
     >  ' Times are in the format hh:mm:ss'
        write(luprt,'(a)') ' Scan   = scan_name command in .snp file'
        write(luprt,'(a)')
     >  ' Line#  = line number in .snp file where this scan starts'
        write(luprt,'(a)')
     >  ' Dur    = time interval of on-source data (Start Data to'//
     >  ' Stop Data) in mmm:ss'
! last line depends on what we are.
        if(ks2) then
          write(luprt,'(a)')
     >   ' Group (min) = group number and nearest minute on tape (S2)'
        elseif(kk4) then
          write(luprt,'(a)')
     >   ' Counts = tape counts at start of scan'
        else if(km5 .or. km5p) then
          write(luprt,'(a)')
     >   ' Gbyte  = Gigabytes at start of scan'
        else
          write(luprt,'(a)')
     >   ' Feet   = footage at start of scan, to nearest 10 feet'
        endif
        writE(luprt,'(a)') ' Record Usage:  XXX'//
     >   '    or Rec1=start recorder 1, Rec2=start recorder 2'
        write(luprt,'(a)')
     >   '              *=parity check, @=no tape motion'
        write(luprt,'()')
C
C  2. Column heads.

        if (.not.kwrap) cbuf='                            '//
     .    '       Start'
        if (     kwrap) cbuf='                            '//
     .    '             Start'
        il=trimlen(cbuf)
        if (kearl.or.kcont) cbuf=cbuf(1:il)//'     Start'
        il=trimlen(cbuf)
        cbuf=cbuf(1:il)//'     Stop'
        il=trimlen(cbuf)
        if (kcont) cbuf=cbuf(1:il)//'     Stop'
        il=trimlen(cbuf)
        if (ks2) then
            cbuf=cbuf(1:il)//'             Record' ! no stops
        else
            cbuf=cbuf(1:il)//'                      Record '
        endif
        il=trimlen(cbuf)
        write(luprt,'(a)') cbuf(1:il)
        cbuf=' Scan      Line#  Source   Az El'
        il=trimlen(cbuf)
        if (kwrap) cbuf=cbuf(1:il)//' Cable'
        il=trimlen(cbuf)
        if (kearl.or.kcont) cbuf=cbuf(1:il)//'  Record'
        il=trimlen(cbuf)
        if (.not.kearl) cbuf=cbuf(1:il)//'    Data      Data'
        if (kearl.or.kcont) cbuf=cbuf(1:il)//'      Data      Data'
        il=trimlen(cbuf)
        if (kcont) cbuf=cbuf(1:il)//'   Record'
        il=trimlen(cbuf)
        if(kmv) then
           cbuf=cbuf(1:il)//'      Dur  Pass Feet Usage'
        else if(ks2) then
           cbuf=cbuf(1:il)//'      Dur  Group (min)'
        else if(km5 .or. km5p) then
           cbuf=cbuf(1:il)//'      Dur    Gbyte'
        else if(kk4) then
           cbuf=cbuf(1:il)//'      Dur  Counts Usage'
        else
           cbuf=cbuf(1:il)//'      Beats me!!'
        endif
        il=trimlen(cbuf)
        write(luprt,'(a)') cbuf(1:il)

        call wrday(luprt,itime_start(1),itime_start(2))
        iline=0
      endif ! new page, write header

! Indicate a day change.
      if(iline .ne. 0 .and. itime_start(2) .ne. iday_old) then
         call wrday(luprt,itime_start(1),itime_start(2))
         iline=iline+1
      endif
      iday_old=itime_start(2)

!  Parse the source info buffer.
!  3.  Now write the scan line
!     mjd = julda(1,idd,iyear-1900)

      iaz = 0
      iel = 0

      ns = index(cbuf_source,',')-1
      csor = cbuf_source(8:ns)
      ns2 = ns+2+index(cbuf_source(ns+2:),',')-2
      if (csor.ne.'AZEL') then ! celestial source
        read(cbuf_source(ns+2:ns2),'(i2,i2,f4.1)') irh,irm,sec
        rarad = (irh+irm/60.d0+sec/3600.d0)*PI/12.d0
        ns3 = ns2+2+index(cbuf_source(ns2+2:),',')-1
        read(cbuf_source(ns2+2:ns2+2),'(a1)') csgn
        if (csgn.eq.'-'.or.csgn.eq.'+') ns2=ns2+1

        read(cbuf_source(ns2+2:ns3),'(i2,i2,f4.1)') ideg,imin,sec
        dcrad = (ideg+imin/60.d0+sec/3600.d0)*PI/180.d0
        if (csgn.eq.'-') dcrad=-dcrad
        ns4 = ns3+index(cbuf_source(ns3+2:),',')
        if (ns4.gt.ns3) then
          read(cbuf_source(ns4+2:),'(a)') cwrap
        else
          cwrap=' '
        endif
! Compute the az and el
        if (kazel) then
          mjd=julda(1,itime_start(2),itime_start(1)-1900)
          ut=itime_start(3)*3600.d0+itime_start(4)*60.d0+itime_start(5)
          call cazel(rarad,dcrad,xpos,ypos,zpos,mjd,ut,az,el)
          iaz = (az*180.d0/PI)+0.5
          iel = (el*180.d0/PI)+0.5
        endif
      else ! satellite AZEL
        ns2 = ns+2+index(cbuf_source(ns+2:),'D')-2
        read(cbuf_source(ns+2:ns2),*) az
        ns3 = ns2+2+index(cbuf_source(ns2+2:),'D')-2
        read(cbuf_source(ns2+3:ns3),*) el
        iaz=az
        iel=el
      endif

      cscan(9:9) = lower(cscan(9:9))
      write(luprt,'(1x,a9,1x,i5,1x,a8,1x,i3,1x,i2,$)') 
     .cscan,nsline,csor,iaz,iel
C  Cable wrap field
      if (kwrap) write(luprt,'(1x,a5,$)') cwrap
C  Early start, "Tape Start" field
      if (kearl.or.kcont) then
        if(ktimedif(itime_tape_start,itime_tape_start_old)) then
          write(luprt,9100) itime_tape_start(3),
     >              itime_tape_start(4),itime_tape_start(5)
        else
          write(luprt,9102)
        endif
      endif

C  "Data Start" field
      write(luprt,9100) itime_start(3),itime_start(4),itime_start(5)
C  "Data Stop" field
      write(luprt,9100) itime_end(3),itime_end(4),itime_end(5)
C  Continuous or adaptive, "Tape Stop" field. Only output if changes.
      if (kcont) then
        if(ktimedif(itime_tape_stop,itime_tape_stop_old)) then
          write(luprt,9100) itime_tape_stop(3),
     >              itime_tape_stop(4),itime_tape_stop(5)
        else
          write(luprt,9102)
        endif
      endif
      do i=1,5
        itime_tape_start_old(i)=itime_tape_start(i)
        itime_tape_stop_old(i)=itime_tape_stop(i)
      end do

9100  format(2x,i2.2,":",i2.2,":",i2.2,$)
!9102  format(2x,2x,  ":",2x,  ":",2x,$)
9102  format("    :  :  ",$)
C  Duration

      idurm = idur/60
      idurs = idur - idurm*60
      write(luprt,'(2x,i3,":",i2.2,$)') iDurM,iDurS
C  Pass
      if (.not.(kk4 .or. km5 .or. km5p)) then ! pass or S2 group
        if (cnewtap.eq.'@   ') then
          write(luprt,'(1x,"--",$)') 
        else
          write(luprt,'(1x,a2,$)') cpass
        endif
      endif ! pass or S2 group
C  Footage
      if (kmv) then
        ifeet_print = 10*ifix((counter+5.)/10.) ! nearest 10 feet
        if (cnewtap.eq.'@   ') then
          write(luprt,'("-",1x,i5,$)') ifeet_print
        else
          write(luprt,'(a1,1x,i5,$)') cdir(1:1),ifeet_print
        endif
      else if(ks2) then
        write(luprt,'(i5,$)') int(counter/60.+.5)  !convert seconds to minutes.
      else if(km5 .or. km5p) then
        write(luprt,'(f8.1,$)') counter/1024.  !convert megabytes to Gigabytes
      else if(kk4) then
        write(luprt,'(i7,$)') int(counter)      !counts
      endif
C  New tape flag
      write(luprt,'(1x,a)') cnewtap

      iline=iline+1
      num_scans = num_scans + 1 ! count of observations
      if (cnewtap(1:3).eq.'XXX'.or.
     .    cnewtap(1:3).eq.'Rec') ntapes=ntapes+1

      return
      end
