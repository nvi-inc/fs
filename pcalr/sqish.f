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
      subroutine sqish(iw,iwbit,jw,jwbyt,nbytes,iperr,table)
      implicit none
      integer*2 iw(1),jw(1)
      integer iwbit,jwbyt,nbytes,iperr,table(256)
c
c original assembler comments:
c
c*STARTING WITH BIT IWBIT OF WORD IW, SQUEEZES OUT PARITY BITS FROM
c*NBYTES 9-BIT CHARS AND PLACES THE RESULTS (NBYTES 8-BIT CHARS) INTO
c*JW STARTING AT BYTE JWBYT. MAX VALUE OF NBYTES IS 3640-IWBIT 9.
c*INCREMENTS IPERR FOR EVERY EVEN PARITY BYTE FOUND. 
c*ON RETURN, IWBIT=IWBIT+9*NBYTES AND JWBYT=JWBYT+NBYTES.
c*FIRST BIT IN IW IS BIT #1. 
c*FIRST BYTE IN JW IS BYTE #1. 
c* 
c*NOTE!!!--IWBIT,JWBYT,IPERR MAY BE MODIFIED ON RETURN!!!! 
c
      integer ibyte,ibit,icount,jchar,out,byte,jibits
c
c  our caller numbers bit 1 as most signifcant       
c                     and byte 1 as first
c  so we will also, using arithmetic in calls to ibits and mvbits
c     to get the correct arguments
c
      ibyte=1+(iwbit-1)/8
      ibit=1+mod(iwbit-1,8)
c      
      if(nbytes.le.0) return
      icount=nbytes      
      iwbit=iwbit+9*nbytes
c
c first word or start of a new word of iw
c
5     continue
      byte=jchar(iw,ibyte)
      ibyte=ibyte+1
c
c store what we have so far
c
10    continue
      call jmvbits(byte,0,9-ibit,out,ibit-1)
c      
c get next byte
c
      byte=jchar(iw,ibyte)
      ibyte=ibyte+1
c      
c store what we need
c
      if(ibit.ne.1) call jmvbits(byte,9-ibit,ibit-1,out,0)
c      
c put output byte in array
c
      call pchar(jw,jwbyt,out)
      jwbyt=jwbyt+1
c
c  check parity, if even, it's an error
c
      if(mod(table(1+out)+jibits(byte,8-ibit,1),2).eq.0) iperr=iperr+1
c      
c  check loop count
c
      icount=icount-1
      if(icount.eq.0) return
c      
c  increment bit count, and loop
c
      ibit=1+mod(ibit,8)
      if(ibit.eq.1) goto 5
      goto 10
c
      end
