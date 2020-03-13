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
      subroutine tmlis(ias,ifc,iec,itlis,ierr)
C 
C     TMLIS 
C 
C 1.  TMLIS PROGRAM SPECIFICATION 
C 
C 1.1.   TMLIS parses and decodes the SNAP <timelist> 
C 
C 1.2.   RESTRICTIONS - limits on use of routine
C 
C 1.3.   REFERENCES - document cited
C 
C 2.  TMLIS INTERFACE 
C 
C 2.1.   CALLING SEQUENCE: CALL TMLIS(III,III,...,OOO,OOO,...)
C 
C     INPUT VARIABLES:
C 
      integer*2 ias(1)
C               - string array
C        IFC,IEC- first,last characters of timelist in IAS
C 
C     OUTPUT VARIABLES: 
C 
C        IERR   - error return
      dimension itlis(3,3)
C      ITIME - time list parameters                       781204
C              3 words each: start, period, stop. 
C                   ITIME(1,1) - start (IYR-1970)*1024 + IDAY 
C                   ITIME(2,1) - start HR*60+MIN
C                   ITIME(3,1) - start SEC*100 + MSEC/10
C                   ITIME(1,2) - period resolution code 
C                              1=msec/100    2=sec   3=min
C                   ITIME(2,2) - period multiplier (value)
C                   ITIME(3,2) - not used 
C                   ITIME(1,3) - stop (IYR-1970)*1024 + IDAY
C                   ITIME(2,3) - stop HR*60 + MIN 
C                   ITIME(3,3) - stop SEC*100 + MSEC/10 
C 
C 2.2  COMMON 
C 2.3.   DATA BASE ACCESSES 
C 2.4.   EXTERNAL INPUT/OUTPUT
C 2.5.   SUBROUTINE INTERFACE:
C 
C     CALLING SUBROUTINES: SPARS
C 
C     CALLED SUBROUTINES: GTTIM 
C 
C 3.  LOCAL VARIABLES 
C 
C        ICC1   - first comma location
C        ICC2   - second comma location 
      integer ichcm_ch
      dimension itnow(5)
C               - current time for comparing
C 
C 4.  CONSTANTS USED
C 
C 5.  INITIALIZED VARIABLES 
C 
C 6.  PROGRAMMER: nrv 
C     LAST MODIFIED: created 781204 
C# LAST COMPC'ED  870115:04:21 #
C
C     PROGRAM STRUCTURE
C
C     1. First initialize.  Check for a "cancel" condition.
C
      if (ifc.gt.iec) then       !! WE HAVE AN EMPTY LIST.
        itlis(1,1) = -2
        goto 999
      endif
C
C  2. THIS IS THE FIRST FIELD SECTION: START TIME.
C
      icc1 = iscn_ch(ias,ifc,iec,',')
      if (icc1.eq.0) icc1=iec+1
      if (ichcm_ch(ias,ifc,'!+').eq.0) then
        ifc=ifc+2
        call gttim(ias,ifc,icc1-1,1,itlis(1,1),itlis(2,1),itlis(3,1),
     .           ierr)
        call reftm(itnow,itlis,'!')
      else
        call gttim(ias,ifc,icc1-1,0,itlis(1,1),itlis(2,1),itlis(3,1),
     .           ierr)
C                   DECODE THE START TIME
      endif
  
      if (ierr.ne.0) goto 999
      if (icc1.ge.iec) goto 999
C                   THERE WAS ONLY A START TIME
C
C
C  3. There is more after the first comma.  Decode next field: period.
C
      icc2 = iscn_ch(ias,icc1+1,iec,',')
      if (icc2.eq.0) icc2=iec+1
      call gttim(ias,icc1+1,icc2-1,1,itlis(1,2),itlis(2,2),itlis(3,2),
     .           ierr)
C                   Decode the period 
      if (ierr.ne.0) goto 999 
C 
C  3.1 Convert period to resolution and multiplier, a la HP time fields. 
C
      if (itlis(3,2).eq.0) then 
C             NO SEC OR MSEC SPECIFIED, ONLY MINUTES, SO USE THAT. 
        itlis(1,2) = 3
        goto 390
      endif
      tsec=itlis(2,2)*60.0 + itlis(3,2)/100.0 
C
C COMPUTE TOTAL NUMBER OF SECONDS IN PERIOD 
C
      if (tsec*100.0.le.32000) then !!PERIOD WILL FIT INTO HUNDREDTHS FIELD. 
        itlis(2,2) = tsec*100.0 
        itlis(1,2) = 1
        goto 390
      endif
C
      if (tsec.le.32000) then      !!PERIOD FITS INTO SECONDS
        itlis(2,2) = tsec 
        itlis(1,2) = 2
        goto 390
      endif
C
      itlis(2,2) = tsec/60.0       !!PERIOD FITS INTO MINUTES 
      itlis(1,2) = 3
C
390   if (icc2.ge.iec) goto 999
C
C
C     4.  There is more after the second comma: stop time.
C
      if (ichcm_ch(ias,icc2+1,'!+').eq.0) then
      icc2=icc2+2
      call gttim(ias,icc2+1,iec,1,itlis(1,3),itlis(2,3),itlis(3,3),
     .           ierr)
      call reftm(itnow,itlis(1,3),'!')
      else
      call gttim(ias,icc2+1,iec,0,itlis(1,3),itlis(2,3),itlis(3,3),
     .           ierr)
      endif
      if (ierr.ne.0) goto 999
      it11 = itlis(1,1)
      it21 = itlis(2,1)
      it31 = itlis(3,1)
      it13 = itlis(1,3)
      it23 = itlis(2,3)
      it33 = itlis(3,3)
C
      if (it11.eq.-1) then
        call fc_rte_time(itnow,iy)
        it11 = (iy-1970)*1024 + itnow(5)
        it21 = itnow(4)*60 + itnow(3) 
        it31 = itnow(2)*100 + itnow(1)
      endif
C 
      if (it11/1024.ne.it13/1024) ierr=-10
C
C NOT POSSIBLE TO SCHEDULE OVER A YEAR BOUNDARY 
C
      if ((it11.gt.it13).or.(it11.eq.it13.and.
     .     it21.gt.it23).or.(it11.eq.it13.and. 
     .     it21.eq.it23.and.it31.gt.it33)) ierr=-11
C
C STOP TIME MUST BE GREATER THAN START
C 
999   continue
      return
      end 
