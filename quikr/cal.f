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
      subroutine cal(ip)
C  cal signal command c#870115:04:37# 
C 
C     This routine handles the CAL command
C 
      include '../include/fscom.i'
C 
C  INPUT: 
C 
      dimension ip(5) 
C     IP(1) - class with command
C 
C  OUTPUT:
C 
C     IP(1) - class with response 
C     IP(2) - number of records 
C     IP(3) - error 
C     IP(4) - who we are
C 
C  LOCAL: 
C 
      integer*2 ibuf(10)
      dimension ireg(2) 
      integer get_buf,ichcm_ch
      dimension iparm(2)
      character cjchar
      equivalence (ireg(1),reg), (iparm(1),parm)
C 
C  INITIALIZED: 
C 
      data ilen/20/ 
C      - length of IBUF 
C 
C  PROGRAMMER: NRV
C  LAST MODIFIED: CREATED 800831
C 
C 
C     1. First get the command and see whether we are to
C     set or report the cal status. 
C 
      iclcm = ip(1) 
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) goto 500
C 
      ierr = 0
      iclass = 0
      nrec = 0
      nch = ieq+1 
      call gtprm(ibuf,nch,nchar,0,parm,ierr) 
      if (cjchar(parm,1).ne.',') goto 211
      ierr = -101 
      goto 990
211   if (cjchar(parm,1).ne.'*') goto 212
      ical = lswcal 
      goto 300
212   ical = -1 
      if (ichcm_ch(parm,1,'on').eq.0) ical = 1 
      if (ichcm_ch(parm,1,'off').eq.0) ical = 0 
      if (ical.ne.-1) goto 300
      ierr = -201 
      goto 990
C 
C 
C     3. Parameters are OK.  Put into COMMON and set the switch.
C     We are using the VHF switch protocol, and assuming that 
C     the "cal on" signal is in position A1 while 
C     the "cal off" is in position A2.
C 
300   lswcal = ical 
C 
      ibuf(1) = 2 
      call char2hol('cl',ibuf(2),1,2)
      if (lswcal.eq.0) call char2hol('a1',ibuf(3),1,2)
      if (lswcal.eq.1) call char2hol('a2',ibuf(3),1,2)
      iclass = 0
      call put_buf(iclass,ibuf,-6,'fs','  ') 
      call run_prog('ibcon','wait',iclass,1,idum,idum,idum) 
      call rmpar(ip)
      return
C 
C 
C     5. Here report the cal switch status. 
C
500   nch = ichmv_ch(ibuf,nchar+1,'/')
      if (lswcal.eq.0) nch=ichmv_ch(ibuf,nch,'off')
      if (lswcal.eq.1) nch=ichmv_ch(ibuf,nch,'on')
      nch = nch-1
      iclass = 0
      call put_buf(iclass,ibuf,-nch,'fs','  ')
      nrec = 1
C
C
990   ip(1) = iclass
      ip(2) = nrec
      ip(3) = ierr
      call char2hol('qc',ip(4),1,2)
      ip(5) = 0
C
      return
      end
