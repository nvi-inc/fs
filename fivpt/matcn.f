*
* Copyright (c) 2020, 2022 NVI, Inc.
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
      subroutine matcn(icmnd,nout,itrig,indata,nin,nreq,ierr) 
C 
C        ICMND = BUFFER HOLDING DATA TO GO OUT
C 
C        NOUT = POSITIVE WORDS OR NEGATIVE CHARACTERS IN ICMND
C 
C        ITRIG = TRIGGER CHARACTER IN LOWER BYTE, UPPER BYTE NULL
C 
C        NIN = POSITIVE WORDS OR NEGATIVE CHARACTERS IN INDATA
C 
C        NREQ = NUMBER OF REQUIRED CHARACTERS IN RESPONSE, POSITIVE 
C 
C  OUTPUT:
C 
C        INDATA = RETURN BUFFER 
C 
C        IERR = 0 IF NO ERROR 
C 
      include '../include/fscom.i'
C 
c     character*1 cjchar
      integer*2 lwho,ibuf(80),indata(1)
      integer nrecs,ichmv,get_buf
      integer*4 iclass,ip(5)
      dimension ireg(2) 
      equivalence (reg,ireg)
      logical kbreak
C 
      data idum/0/,lwho/2Hfp/,ntry/2/
  
C 
      iter=ntry
      ni=nin
      if (nin.gt.0) ni=-2*nin
12    continue
      iter=iter-1
      if (iter.lt.0) goto 80000
      if (kbreak('fivpt')) goto 80010
      nrecs=0
      iclass=0
c
      ibuf(1)=5
      inextc=1
      inextc=ichmv(ibuf(2),inextc,icmnd,1,-(nout+1))
      inextc=ichmv(ibuf(2),inextc,itrig,1,1)
      call put_buf(iclass,ibuf,-(1+inextc),'  ','  ')
c     write(6,9953) inextc-1,(cjchar(ibuf,2+i),i=1,inextc-1)
9953  format(' inextc ',i10,' ibuf ',20a1)
      nrecs=nrecs+1
c
      call run_matcn(iclass,nrecs)
      call rmpar(ip)
      if(ip(1).gt.0) then
        nchars=nin
        if(nin.gt.0) nchars=-2*nin
        nchars=get_buf(ip(1),indata,nchars,irtn1,irtn2)
c     write(6,9954) nreq,nchars,(cjchar(indata,i),i=1,nchars)
9954  format(' nreq ',i10,' inextc ',i10,' ibuf ',20a1)
        ip(2)=ip(2)-1
      endif
      if(ip(2).gt.0) call clrcl(ip(1))
C
C      CHECK FOR TIME OUT
C
      if (ip(3).ne.-4) goto 14
      call logit6(idum,idum,idum,-1,-70,lwho)
      goto 12
C
C       CHECK FOR CHARACTER COUNT ERROR
C
14    continue
      if(ip(3).ne.-5) goto 15
      call logit6(idum,idum,idum,-1,-71,lwho)
      goto 12
C
C  other errors
C
15    continue
      if(ip(3).ge.0) goto 90000
      call logit7(idum,idum,idum,-1,ip(3),ip(4),ip(5))
      goto 12
C 
C  FAILED 
C 
80000 continue
      ierr=-72
      goto 90000 
C 
C BREAK DETECTED
C 
80010 continue
      ierr=-1 
      goto 90000 
C 
C CLEAN UP AND EXIT 
C 
90000 continue

      return
      end 
