*
* Copyright (c) 2020 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
      subroutine lstsumo(kskd,itearl_local,itlate_local,maxline,
     >   iline,npage,num_scans,ntapes,             !These are modified by this routine
     >   nsline,
     >   itime_start,itime_end,itime_tape_start,itime_tape_stop,
     >   iDur,counter,cpass,cnewtap,cdir,cscan,cbuf_source)

      implicit none 
      include 'hardware.ftni'
      include '../skdrincl/constants.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/freqs.ftni'
      include 'lstsum.ftni'

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
! 2004Nov05 JMGipson.  Modified so that only put complete header info on first page.
! 2006Jul29 JMGipson.  Don't put out line numbers if we don't have a start.
! 2006Sep26 JMGipson.  Made call to setup name ASCII (csetup_name used to be hollerith)
! 2006Oct06 JMGipson.  Fixed extraneous comma in write statement that caused compiler problems
!                      for some linux versions.
! 2006Nov09 JMGipson.  1st page was 1 line longer than others. Fixed.
! 2006Nov30 JMGipson. Changed to use cstrec(istn,irec).
! 2007Jul28 JMGipson. Replace kdisk by kdisk which is in hardware.ftni
! 2008Jan07 JMGipson.  Changed so that will ALWAYS print line numbers if recorder type is none.
!             Previously relied on recorder starting and stopping info, which is absent in the "none" case.
! 2014Jan17 JMGipson. Modified call to setup_name.  Removed pass info. 

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
      integer iDur		         !duration in min, seconds
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
      double precision rarad_prcs,dcrad_prcs   !precessed positions.
      real*8 tjd         
      character*7 cwrap
      double precision az,el

      integer idurm,idurs              !duration in minutes,seconds.
      character*1 csgn
      integer imin, ideg
      real sec
      integer irh,irm
      integer ns,ns2,ns3,ns4
      logical knew_start

C Local
      integer i,il,iaz,iel
      logical kcont,kearl
!
! Saved local variables.
      integer iday_old
      save iday_old
      integer itime_tape_stop_old(5)
      integer itime_tape_start_old(5)
      save itime_tape_stop_old,itime_tape_start_old

      integer mjd                       !MJD of scan.
      double precision ut              !UT of scan

! Used to output proc names
      integer icode
      character*12 csetup_name

      integer*2 lcodeTmp
      character*2 ccodetmp
      equivalence (ccodetmp,lcodetmp)     
      integer num_sub_pass,num_recs
      character*12 lfilnam
! tape type    
      logical kprint_doy 
      kprint_doy=.false.   

! Initialize
      if(npage .eq. 0 .and. iline .eq. maxline) then
        do i=1,5
         itime_tape_start_old(i)=0
         itime_tape_stop_old(i)=0
        end do
      endif

      kmv=.not.(ks2.or.kk4 .or. kdisk) ! kmv=Mk3/4 or VLBA
      kcont=.true. ! if we don't know, include the column
      if (kskd) kcont=tape_motion_type(istn).eq.'CONTINUOUS'.or.
     >                tape_motion_type(istn).eq.'ADAPTIVE'  .or.
     >                itlate(istn).gt.0
      kearl=itearl_local.gt.0

!********* START OF HEADER INFORMATION********************************************************
C  1. Headers.
      if (iline.ge.maxline) then ! new page, write header
        if (npage.gt.0) call luff(luprt)
        npage = npage + 1
        call strip_path(cinname,lfilnam)

        write(luprt,9200) lfilnam,npage
9200      format(' Schedule file: ',2x,a12,10x,'Page ',i3)
        iline=1

! Various header information.
        if(npage .eq. 1) Then
          if (kskd) then
            write(luprt,9201) cstnna(istn),cpocod(istn),
     .      cstcod(istn),cexper
9201        format(' Station:    ',5x,a8,' (',a2,') (',a1,')',4x,
     .           ' Session:    ',5x,a)
          else
            write(luprt,9203) cstn,cid,cexpername
9203        format(' Station: ',9x,a8,' (',a2,')', 7x,'Session:    ',a8)
            if(kdisk) then
              write(luprt)
     >         "Warning! Can't give byte-count without schedule file."
            else if(kk4) then
              write(luprt)
     >         "Warning! Can't give count without schedule file."
            endif
          endif

          if(kskd) then
            i=trimlen(tape_motion_type(istn))
            if(i .ne. 0) then
              if(tape_motion_type(istn) .eq. "ADAPTIVE") then
                write(luprt,9204) itgap(istn)
9204            format(" Tape motion:     ADAPTIVE (gap=",i3,")",3x,$)
              else
                write(luprt,9205) tape_motion_type(istn)(1:10)
9205            format(" Tape motion:     ",a,11x,$)
              endif
            endif
      
            if(kdisk) then
              write(luprt,  '(" Recorder type:   DISK")')
            else
             
            endif
          endif            !end kskd

          write(luprt,9210)  cstrack(istn)
9210      format(" Rack:            ",a)
          write(luprt, 9211)    cstrec(istn,1),itearl_local
9211      format(" Recorder 1:      ",a,14x,"Early start: ",i6,1x,"sec")
          write(luprt, 9212)    cstrec(istn,2),itlate_local
9212      format(" Recorder 2:      ",a,14x,"Late  stop:  ",i6,1x,"sec")


! Put out procedure names

          num_recs=nrecst(istn)
          if(nrecst(istn) .eq. 2) then
            if(crecb .eq. "unused" .or. crecb .eq. "none") then
               num_recs=1
             endif
          endif
          iline=6

          do icode=1,ncodes
            do irec=1,num_recs ! loop on number of recorders
              num_sub_pass=npassf(istn,icode)
              if(kdisk)  num_sub_pass=1
              write(luprt, '(" Mode",i2," Setup proc(s): ",$)') icode
              call setup_name(ccode(icode),csetup_name)                
              write(luprt,'(a,1x,$)') csetup_name            
              lcodeTmp=lcode(icode)
              call c2lower(ccodetmp,ccodetmp)
              write(luprt,'(1x,"IFD proc: ifd",a2)') ccodetmp
              iline=iline+1
            end do
          end do
! End of put out procedure names.
         if(km6disk) then 
           write(luprt,
     > '(" Mark6 recorder group size is", i2, " modules ")') 
     >         isink_mbps(istn)/4096
         endif 

! write out additional info.
          iline=iline+9

          write(luprt,'()')
          write(luprt,'(a)')
     >    ' Times are in the format hh:mm:ss'
          write(luprt,'(a)') ' Scan   = scan_name command in .snp file'
          write(luprt,'(a)')
     >    ' Line#  = line number in .snp file where this scan starts'
          write(luprt,'(a)') ' Dur    = time interval of on-source '//
     >       'data (Start Data to  Stop Data) in mmm:ss'
! last line depends on what we are.
          if(ks2) then
            write(luprt,'(a)')
     >     ' Group (min) = group number and nearest minute on tape (S2)'
          elseif(kk4) then
            write(luprt,"(' Counts = tape counts at start of scan')")
          else if(kdisk) then
            write(luprt,"(' Gbyte  = Gigabytes at start of scan')")
          endif
          writE(luprt,'(a)') ' Info:  XXX'//
     >     '    or Rec1=start recorder 1, Rec2=start recorder 2'
          write(luprt,'(a)')
     >     '              *=parity check, @=no tape motion'
          write(luprt,'()')
        endif           !end of other information.

C
C  2. Column heads.
        iline=iline+4

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
            cbuf=cbuf(1:il)//'                       '
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
       
        if(kdisk .or. cstrec(istn,1) .eq. "Mark6") then 
           if(kskd) then
             cbuf=cbuf(1:il)//'      Dur    Gbyte'
           else
             cbuf=cbuf(1:il)//'      Dur '
           endif      
        else
            cbuf=cbuf(1:il)//'      Dur '
        endif 
        il=trimlen(cbuf)
        cbuf=cbuf(1:il)//'  Info'
        il=trimlen(cbuf) 
        write(luprt,'(a)') cbuf(1:il)
        call wrday(luprt,itime_start(1),itime_start(2))
        kprint_doy=.true.
      endif ! new page, write header

!*****END OF HEADER*************************************************

! Indicate a day change.
      if(.not.kprint_doy .and. itime_start(2) .ne. iday_old) then
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
        rarad = (irh+irm/60.d0+sec/3600.d0)*ha2rad
        ns3 = ns2+2+index(cbuf_source(ns2+2:),',')-1
        read(cbuf_source(ns2+2:ns2+2),'(a1)') csgn
        if (csgn.eq.'-'.or.csgn.eq.'+') ns2=ns2+1

        read(cbuf_source(ns2+2:ns3),'(i2,i2,f4.1)') ideg,imin,sec
        dcrad = (ideg+imin/60.d0+sec/3600.d0)*deg2rad
        if (csgn.eq.'-') dcrad=-dcrad
        ns4 = ns3+index(cbuf_source(ns3+2:),',')
        if (ns4.gt.ns3) then
          read(cbuf_source(ns4+2:),'(a)') cwrap
        else
          cwrap=' '
        endif
! Compute the az and el
        mjd=julda(1,itime_start(2),itime_start(1)-1900)
        tjd=mjd+2440000.d0
      
! Should really get the epoch from the snap line. But we know that the epoch
! in the snap line is generated based on cepoch. 
        if(cepoch .eq. '1950') tjd=tjd+18262
        call apstar_Rad(tjd, rarad, dcrad, rarad_prcs,dcrad_prcs)
           
        if (kazel) then    
          ut=itime_start(3)*3600.d0+itime_start(4)*60.d0+itime_start(5)
          call cazel(rarad_prcs,dcrad_prcs,xpos,ypos,zpos,mjd,ut,az,el)
          iaz = (az*rad2deg)+0.5
          iel = (el*rad2deg)+0.5
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
      knew_start=ktimedif(itime_tape_start,itime_tape_start_old)   
      write(luprt,'(1x,a9,1x,$)') cscan

      if(knew_start.or.ks2 .or. cstrec(istn,1) .eq. "none") then
         write(luprt,'(i5,$)') nsline
      else
         write(luprt,'("     ",$)')
      endif
      write(luprt,'(1x,a8,1x,i3,1x,i2,$)') csor,iaz,iel

C  Cable wrap field
      if (kwrap) write(luprt,'(1x,a5,$)') cwrap
C  Early start, "Tape Start" field
      if (kearl.or.kcont) then
        if(knew_start) then
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

9102  format("    :  :  ",$)
C  Duration

      idurm = idur/60
      idurs = idur - idurm*60
      write(luprt,'(2x,i3,":",i2.2,$)') iDurM,iDurS

C  Footage     
      if(kdisk) then
        if(kskd) then
          write(luprt,'(f8.1,$)') counter/1024  !convert megabytes to Gigabytes
        endif    
      endif

      write(luprt,'(3x,a)') cnewtap

      iline=iline+1
      num_scans = num_scans + 1 ! count of observations
      if (cnewtap(1:3).eq.'XXX'.or.
     .    cnewtap(1:3).eq.'Rec') ntapes=ntapes+1

      return
      end
