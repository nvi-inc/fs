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
      subroutine pedis(ip,iclcm,perr,isyner,indxtp)
C  parity error display c#870115:04:38#
C 
C   PEDIS displays parity errors
C 
C     INPUT VARIABLES:
C 
      dimension ip(1) 
C      - RMPAR parameters from PERR 
      dimension perr(1) 
C      - actual counts from decoder 
C     ISYNER - number of synch errors 
C 
C     OUTPUT VARIABLES: 
C 
C        IP(1) - error
C        IP(2) - class
C        IP(3) - number of records
C        IP(4) - who we are 
C 
C COMMON BLOCKS USED
C 
      include '../include/fscom.i'
C 
C SUBROUTINE INTERFACE: 
C 
C  LOCAL VARIABLES
C 
      logical kcom
      integer*2 ibuf2(30) 
C               - output display buffer 
C        ILEN   - length of buffers, chars
C        NCH    - character counter 
C        I      - bit, converted to 0 or 1
C        IA     - hex char from MAT 
      dimension ireg(2) 
      integer get_buf
      integer*2 lmode(4)
      dimension nmode(2) 
      equivalence (reg,ireg(1)) 
C 
C INITIALIZED VARIABLES 
C 
      data ilen/60/ 
      data lchan/2hab/
      data lmode/2hre,2hc ,2hpl,2hay/ 
      data nmode/3,4/ 
C 
C PROGRAMMER: NRV 
C     LAST MODIFIED: CREATED 800901 
C 
C 
C     1. Get class buffer with command in it.  Set up first part
C     of output buffer. 
C 
      kcom = (ichcm_ch(ip(4),1,'?').eq.0)
C 
      if (iclcm.eq.0) goto 990
      ireg(2) = get_buf(iclcm,ibuf2,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
      ieq = iscn_ch(ibuf2,1,nchar,'=')
      nch = nchar+1 
      if (kcom) nch = ieq 
      nch = ichmv_ch(ibuf2,nch,'/') 
C                   Put / to indicate a response
C 
C 
C     2. Now the buffer contains: PERR/ and we want to add
C     the data. 
C 
      nch = nch + ib2as(itrper(indxtp),ibuf2,nch,o'100000'+2) 
      nch = mcoma(ibuf2,nch)
      nch = ichmv(ibuf2,nch,lchan,ichper(indxtp)+1,1) 
      nch = mcoma(ibuf2,nch)
      nch = nch + ib2as(insper(indxtp),ibuf2,nch,o'100000'+3) 
      nch = mcoma(ibuf2,nch)
      nch = nch + ir2as(tperer(indxtp),ibuf2,nch,5,1) 
      nch = mcoma(ibuf2,nch)
      nch = ichmv(ibuf2,nch,lmode,imodpe(indxtp)*4+1,
     $     nmode(imodpe(indxtp)+1)) 
      if (kcom) goto 500
      nch = mcoma(ibuf2,nch)
C 
C     2.1 Average the parity error counts and add 
C     to output buffer. 
C 
      sum = 0.0 
      do 350 i=1,insper(indxtp) 
        perr(i) = perr(i+1)-perr(i) 
C                   The number of parity errors is the difference 
C                   between successive readings 
        sum = sum + perr(i) 
350     continue
      sum = sum/(insper(indxtp))
C 
      nch = nch + ir2as(sum,ibuf2,nch,6,1)
      nch = mcoma(ibuf2,nch)
      nch = nch + ib2as(isyner,ibuf2,nch,o'100000'+5) 
C 
C 
C     5. Now send the buffer to SAM.
C 
500   iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf2,-nch,'fs','  ')
C                   Send buffer to display
C 
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = 0 
      call char2hol('qj',ip(4),1,2)
990   return
      end 
