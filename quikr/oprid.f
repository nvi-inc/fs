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
      subroutine oprid(ip)
C  operator id c#870115:04:53#
C 
C     OPRID gets/displays the operator's name 
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of input parameter buffer. 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - CLASS #
C        IP(2) - # RECORDS IN CLASS 
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
      include '../include/fscom.i'
C 
C     CALLED SUBROUTINES: CHARACTER ROUTINES
C 
C   LOCAL VARIABLES 
C        NCHAR  - number of characters in buffer
C        NCH    - character counter 
      integer*2 ibuf(20)                    !  class buffer
      dimension ireg(2)                     !  registers from exec calls
      integer get_buf
      dimension iparm(2)                    !  parameters from gtparm
      character cjchar
      equivalence (reg,ireg(1)) 
      equivalence (parm,iparm(1)) 
C 
C 5.  INITIALIZED VARIABLES 
      data ilen/40/                         !  length of ibuf, chars
C 
C 6.  PROGRAMMER: NRV 
C     LAST MODIFIED: CREATED  820323
C 
C 
C     1. Get the class buffer.  Messages for the OPRID consist of 
C     a series of LUs, separated by commas. 
C 
      iclcm = ip(1) 
      if (iclcm.eq.0) then
        ierr = -1
        goto 990
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0.or.cjchar(ibuf,ieq+1).eq.'?') goto 500
C 
C     2. Get the parameters from the command. 
C 
      ich = ieq+1 
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
C                   Scan for characters in operator's name
      if (cjchar(parm,1).eq.',') then
        ierr = -101
        goto 990
      endif
      nch = ich-ieq-2
      if (nch.gt.12) then
        ierr = -201
        goto 990
      endif
      call ifill(loprid,1,12,0)                  !  fill name with nulls
      idumm1 = ichmv(loprid,1,ibuf,ieq+1,nch) 
      ierr = 0
      goto 990
C 
C     5. Display current ID.
C 
500   if (ieq.eq.0) ieq = nchar+1 
      nch = ichmv_ch(ibuf,ieq,'/')
C                   Put / to indicate a response
      nch = ichmv(ibuf,nch,loprid,1,12)-1 
C 
      iclass = 0
      call put_buf(iclass,ibuf,-nch,'fs','  ')
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = 0 
      call char2hol('q&',ip(4),1,2)
      return
C 
990   ip(1) = 0 
      ip(2) = 0 
      ip(3) = ierr
      call char2hol('q&',ip(4),1,2)
      return
      end 
