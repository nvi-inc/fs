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
      SUBROUTINE unpbar(IBUF,ILEN,IERR,
     .LCODE,lst,ns,lbar)
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
C     UNPBAR  unpacks the barrel roll line
C
      include '../skdrincl/skparm.ftni'

C  History:
C 960709 nrv New. Copied from UNPRAT.
C 020115 nrv Allow "8" and "16".
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen
C           - buffer having the record
C     ILEN - length of the record in IBUF, in words
C
C  OUTPUT:
      integer ierr
      integer ns ! number of station names
      integer*2 lcode,lbar(2,max_stn),lst(4,max_stn)
C     IERR - error, 0=OK, -100-n=error reading nth field in the record
C     LCODE - frequency code, 2 char
C
C  LOCAL:
      integer nx,ich,nch,ic1,ic2,idumy
      integer ichcm_ch,ichmv
C
C
C     1. Start decoding this record with the first character.
C
      IERR = 0
      ICH = 1
C
C     Frequency code, 2 characters
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.2) THEN  !
        IERR = -101
        RETURN
      END IF  !
      call char2hol ('  ',LCODE,1,2)
      IDUMY = ICHMV(LCODE,1,IBUF,IC1,NCH)
C
C     List of stations and barrels
C
      ns=0 ! station count
      nx=0 ! field count
      do while (ic1.gt.0)
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
        nx=nx+1
        if (ic1.gt.0) then ! station name
          NCH = IC2-IC1+1
          IF  (NCH.GT.8) THEN
            IERR = -101-nx
            RETURN
          END IF
          ns=ns+1
          CALL IFILL(lst(1,ns),1,8,oblank)
          CALL IFILL(lbar(1,ns),1,4,oblank)
          IDUMY = ICHMV(lst(1,ns),1,IBUF,IC1,NCH)
        else
          return
        endif
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
        nx=nx+1
        if (ic1.gt.0) then ! barrel roll
          NCH = IC2-IC1+1
          IF  (NCH.GT.4) THEN
            IERR = -101-nx
            RETURN
          END IF
          if (ichcm_ch(ibuf,ic1,'16:1').ne.0.and.
     .        ichcm_ch(ibuf,ic1,'8:1') .ne.0.and.
     .        ichcm_ch(ibuf,ic1,'8') .ne.0.and.
     .        ichcm_ch(ibuf,ic1,'16') .ne.0.and.
     .        ichcm_ch(ibuf,ic1,'on') .ne.0.and.
     .        ichcm_ch(ibuf,ic1,'ON') .ne.0.and.
     .        ichcm_ch(ibuf,ic1,'none').ne.0.and.
     .        ichcm_ch(ibuf,ic1,'NONE').ne.0) then
            ierr=-101-nx
            return
          else
            IDUMY = ICHMV(lbar(1,ns),1,IBUF,IC1,NCH)
          endif
        else
          ierr=-101-nx
        endif
      enddo
C
      RETURN
      END
