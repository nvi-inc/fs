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
      subroutine matld(ip)
C  mat down-load command c#870115:04:41#
C 
C     MATLD formats a command which downloads to MATs 
C 
C     INPUT VARIABLES:
C 
      dimension ip(1) 
C        IP(1)  - class number of input parameter buffer. 
C 
C     OUTPUT VARIABLES: 
C 
C        IP(1) - CLASS
C        IP(2) - # REC
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
C 
      include '../include/fscom.i'
C 
C 2.5.   SUBROUTINE INTERFACE:
C 
C     CALLING SUBROUTINES:
C 
C     CALLED SUBROUTINES: GTPRM
C 
C 3.  LOCAL VARIABLES 
C 
C     NHXBYT - number of hex bytes (2-char) in data 
C        NCHAR  - number of characters in buffer
C        ICH    - character counter 
      integer*2 ibuf(40)
C               - class buffer, for input and output
cxx      dimension lloc(2) 
      integer*2 lloc(2) 
C                     - location for down load
cxx      dimension ldata(30) 
      integer*2 ldata(30) 
C                     - data bytes to be downloaded 
C        ILEN   - length of IBUF, chars 
cxx      dimension iparm(2)
      integer*2 iparm(2)
C               - parameters returned from GTPRM
      dimension ireg(2) 
      integer get_buf,ichcm_ch
C               - registers from EXEC calls 
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1)) 
C 
C 4.  CONSTANTS USED
C 
C 
C 5.  INITIALIZED VARIABLES 
C 
      data ilen/80/ 
      data idlen/60/
C 
C 
C     PROGRAM STRUCTURE 
C 
C     1. If we have a class buffer, then we are to format a message.
C     If no class buffer, this is an error. 
C 
      iclcm = ip(1) 
      if (iclcm.ne.0) goto 110
      ierr = -1 
      goto 990
110   ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum) 
      nchar = ireg(2) 
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.ne.0) goto 210
      ierr = -101 
      goto 990
C                   If no parameters, ERROR 
C 
C 
C     2. Get the parameters and decode them:
C             MATLOAD=<address>,<location>,<data> 
C     where 
C             <address> is any 2-char hex address 
C             <location> is a 4-char hex location 
C             <data> is the hex data bytes to be sent 
C 
C     PARAMETER 1: MAT ADDRESS
C 
210   ich = 1+ieq 
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 211 
      ierr = -101 
      goto 990
211   ladr = iparm(1)
      iadr1 = ia22h(ladr) 
      if (iadr1.ge.0.and.ichcm_ch(iparm(2),1,' ').eq.0) goto 220 
      ierr = -201 
      goto 990
C 
C     PARAMETER 2: LOCATION 
C 
220   call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 221 
      ierr = -102 
      goto 990
221   idumm1 = ichmv(lloc,1,iparm,1,4)
      iadr1 = ia22h(lloc(1)) 
      iadr2 = ia22h(lloc(2))
      if (iadr1.ge.0.and.iadr2.ge.0) goto 230 
      ierr = -202 
      goto 990
C 
C     PARAMETER 3: DATA BYTES 
C 
230   ic1 = ich 
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 231 
      ierr = -103 
      goto 990
231   nch = ich-1-ic1 
C                     The total number of characters in the data
      if (nch.gt.0.and.nch.le.idlen) goto 232 
      ierr = -203 
      goto 990
232   idumm1 = ichmv(ldata,1,ibuf,ic1,nch)
      nhxbyt = (nch+1)/2
      do 235 i=1,nhxbyt 
        if (ia22h(ldata(i)).ge.0) goto 235
        ierr = -203 
        goto 990
235     continue
C 
C 
C     3. Format the buffer for the MAT.  This will be a mode 5 request. 
C     The buffer looks like:
C               #aa:nnhhll00<data>cc
C     where 
C              aa is the MAT unit address 
C              nn is the total number of hex data bytes 
C              hh is the high order byte of the location
C              ll is the low order byte of the location 
C              00 is an unused spot 
C              <data> is an exact copy of the data bytes typed in 
C              cc is the checksum including everything from the nn to cc. 
C 
300   ibuf(1) = 5 
      call char2hol('#  :',ibuf(2),1,4)
      idumm1 = ichmv(ibuf,4,ladr,1,2) 
      idumm1 = ib2as(nhxbyt,ibuf,7,o'40000'+o'400'*2+2) 
      ibuf(5) = lloc(1) 
      ibuf(6) = lloc(2) 
      call char2hol('00',ibuf(7),1,2)
      idumm1 = ichmv(ibuf,15,ldata,1,nhxbyt*2)
C 
C     Now form the check sum
C 
      do 310 i=4,nhxbyt+4 
        ichks = ichks+ia22h(ibuf(i))
310     continue
      ichks = 256 - mod(ichks,256)
      ibuf(nhxbyt+8) = ih22a(ichks) 
C 
C 
C     8. Schedule MATCN and check for error return. 
C 
      iclass = 0
      nch = (nhxbyt+8)*2
      call put_buf(iclass,ibuf,-nch,'fs','  ') 
      call run_matcn(iclass,1) 
      call rmpar(ip)
      return
C 
C 
C 
990   ip(1) = 0 
      ip(2) = 0 
      ip(3) = ierr
      call char2hol('ql',ip(4),1,2)
      return
      end 
