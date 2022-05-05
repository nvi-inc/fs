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
      subroutine fakesum
C
C     FAKESUM makes a fake LVEX output from the schedule.
C
C 000110 nrv New.
C 000818 nrv New scan name format.
C 001114 nrv Scan names are character now.
! 2004Feb16 JMG.  Fixed some bugs.

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'

      integer TRIMLEN
C
C LOCAL:
      integer*2 LSNAME(max_sorlen/2),LSTN(MAX_STN),LCABLE(MAX_STN)
      integer*2 LMON(2), LDAY(2),LMID(3),LPRE(3),LPST(3),LDIR(MAX_STN)
      character*2 cdir(max_stn)
      equivalence (ldir,cdir)
      integer ipas(max_stn),ift(max_stn),idur(max_stn),ioff(max_stn)
      integer iftold,idir,ituse,iobs,il,ilen,ihead
      character*18 cstart,cstop
      character*128 scan_id
      integer id
      double precision gst,ut
      real speed
      integer iyr,idayr,ihr,imin,isc,mjd,mon,ida,ical,icod,
     .iyr2,idayr2,ihr2,min2,isc2
      integer*2 lfreq
      integer nstnsk,istnsk,isor
      integer ierr
      INTEGER IC
      integer i

      character*(max_sorlen) csname
      character*2 cstn(max_stn)
      character*2 cfreq
      equivalence (csname,lsname),(lstn,cstn),(cfreq,lfreq)

C
C INITIALIZED:
      DATA IFTOLD/0/
C
      call lv_open(ierr) ! get output file name
      il=trimlen(cstnna(istn))
      write(lu_outfile,9100) cstnna(istn)(1:il),cpocod(istn)
9100  format("*FAKE Summary for ",a". Station ID ",a2,".")
      write(lu_outfile,9101) cpocod(istn),cstnna(istn)(1:il)
9101  format("*"/
     .       "  def ",a2,";    * ",a)

      ic=trimlen(lskdfi)
      WRITE(LUSCN,100) cSTNNA(ISTN),LSKDFI(1:ic) ! new
100   FORMAT(' FAKEsum output for ',A,' from schedule ',A) 

      ituse=1

      do i=1,max_stn
        cstn(i)=" "  	!initialize
      end do

      do iobs=1,nobs
        cbuf=cskobs(iskrec(iobs))
        ilen=trimlen(cbuf)
        CALL UNPSK(IBUF,ILEN,LSNAME,ICAL,
     .     LFREQ,IPAS,LDIR,IFT,LPRE,
     .     IYR,IDAYR,IHR,iMIN,ISC,IDUR,LMID,LPST,
     .     NSTNSK,LSTN,LCABLE,
     .     MJD,UT,GST,MON,IDA,LMON,LDAY,IERR,KFLG,ioff)
!        CALL CKOBS(LSNAME,LSTN,NSTNSK,LFREQ,ISOR,ISTNSK,ICOD)
        call ckobs(csname,cstn,nstnsk,cfreq,isor,istnsk,icod)

        IF (ISOR.EQ.0.OR.ICOD.EQ.0) return
C
        IF (ISTNSK.NE.0)  THEN
C THEN BEGIN Current station in observation
          write(cstart,'(i4,"y",i3.3,"d",i2.2,"h",i2.2,"m",i2.2,"s")')
     .     iyr,idayr,ihr,imin,isc
          ID=IDUR(ISTNSK)
          CALL TMADD(IYR,IDAYR,IHR,iMIN,ISC,ID,
     .               IYR2,IDAYR2,IHR2,MIN2,ISC2)
          write(cstop,'(i4,"y",i3.3,"d",i2.2,"h",i2.2,"m",i2.2,"s")')
     .    iyr2,idayr2,ihr2,min2,isc2
          idir=1
          if (cdir(istnsk)(1:1) .eq. "R") idir=-1
          IFTOLD = IFT(ISTNSK)+IFIX(IDIR*(ituse*ITEARL(istn)+
     .      IDUR(ISTNSK)) *speed(icod,istn))
          IHEAD=ihdpos(1,IPAS(ISTNSK),istn,icod)
C       Create scan ID from start time and source
C       ddd-hhmm_source
C       Use scan IDs already generated.
C       write(scan_id,'(i3.3,"-",2i2.2,"_",20a2)') idayr,ihr,imin,
C    .  (lsname(i),i=1,max_sorlen/2)
C       write(scan_id,'(5a2)') (scan_name(i,iobs+1),i=1,5)
        scan_id = scan_name(iobs)
        il=trimlen(scan_id)
        write(lu_outfile,'("    scan ",a,";")') scan_id(1:il)
C       write(lu_outfile,'("    scan ",5a2,";")')
C    .      (scan_name(i,iobs+1),i=1,5)
        write(lu_outfile,'("      VSN = unknown;")')
        write(lu_outfile,'("      head_pos = ",i5," um;")') ihead
        write(lu_outfile,
     >   '("      start_tape = ",a," : ",i5.5," ft : 0 in/sec;")')
     >    cstart,ift(istnsk)
        write(lu_outfile,
     >   '("      stop_tape = ",a," : ",i5.5, " ft ;")') cstop,iftold
        il=trimlen(csorna(isor))
        write(lu_outfile,'("      source = ",a,";")') csorna(isor)(1:il)
        write(lu_outfile,'("    endscan;")')
        endif
      ENDDO
900   continue
      close(lu_outfile)
C
      RETURN
      END
