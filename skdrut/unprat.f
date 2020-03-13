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
      SUBROUTINE unprat(IBUF,ILEN,IERR,
     .LCODE,srate)
C
C     UNPRATE unpacks the sample rate line
C
      include '../skdrincl/skparm.ftni'

C  History:
C 960321 nrv New.
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen
C           - buffer having the record
C     ILEN - length of the record in IBUF, in words
C
C  OUTPUT:
      integer ierr
      integer*2 lcode
      real*4 srate
C     IERR - error, 0=OK, -100-n=error reading nth field in the record
C     LCODE - frequency code, 2 char
C     SRATE - sample rate, MHz
C
C  LOCAL:
      real*8 DAS2B
      real*4 d
      integer ich,nch,ic1,ic2,idumy
      integer ichmv
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
C     Sample rate 
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      D = DAS2B(IBUF,IC1,IC2-IC1+1,IERR)
      IF  (IERR.LT.0) THEN  !
        IERR = -102
        RETURN
      END IF  !
      srate = D
C
      RETURN
      END
