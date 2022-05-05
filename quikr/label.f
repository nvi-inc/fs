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
      subroutine label(ip,itask)
C  check-label command   <910323.0100>
C
C     Calling parameters:
      dimension ip(1)
C        On input:   IP(1) = class # of input parameter buffer
C        On output:  IP(1) = class # of output parameter buffer (if any)
C                    IP(2) = # of records in class IP(1)
C                    IP(3) = error #
C                    IP(4) = subroutine identifier
C
C        COMMON BLOCKS USED
      include '../include/fscom.i'
C          !  contains ltpnum and ltpchk
C
C        SUBROUTINE INTERFACE:     Called by QUIKR
C            Calls LNF's character routines and system utilities only.
C
C     PROGRAMMER:  ANONYMOUS, MISTS OF ANTIQUITY, STYLE OF LEE FOSTER
C                             ^^^^^^^^^^^^^^^^^^
C                             FOGGY REMNANTS OF THE PAST
C     MODIFIED BY:  LAR, March 1988, for labels read by bar code reader
C  WHO  WHEN    DESCRIPTION
C  GAG  910102  Broke compound IF statement concerning PRLAB scheduling
C               into parts.
C
      dimension iparm(2)
      dimension ireg(2)
      integer get_buf,ichcm_ch
C        NCHAR  - number of characters in buffer
C        ICH    - character counter
      integer*2 ibuf(40)           !  class buffer
      integer*2 ibuf2(40)
      integer*2 lnum(4),lchk(2)
C                   - holders for tape number, check label
C                   - program to be RPed, buffer for status request
      integer*2 lbarco(22)                !  ordered list of legal bar codes
      integer*2 ihash,icode
      integer iscns
      character cjchar
      equivalence (ireg(1),reg), (iparm(1),parm)
      data ilen/80/               !  length of ibuf in characters
      data lbarco/2h01,2h23,2h45,2h67,2h89,2hab,2hcd,2hef,2hgh,2hij,
     .            2hkl,2hmn,2hop,2hqr,2hst,2huv,2hwx,2hyz,2h-.,2h $,
     .            2h/+,2h% /
C 
C     1. First check out the input class number.  Then get the command 
C     into a buffer and find the "=" to determine whether to check or 
C     report the tape info. 
C 
      if( itask.eq.3.or.itask.eq.5) then
         indxtp=1
      else
         indxtp=2
      endif
      iclcm = ip(1) 
      do i=1,3         !  set up default output parameters.
        ip(i)=0
      enddo
      call char2hol('qa',ip(4),1,2)
      if (iclcm.eq.0) then
        ip(3) = -1
        return                              !  zero class number
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
      ieq = iscn_ch(ibuf,1,nchar,'=')
C
C     2. If there are no parameters (no =), fill a character buffer with the
C     current tape # and check label, write the buffer to a class, and return
C     the class number to the calling program.
C
      call fs_get_select(select)
      if((select.eq.0.and.itask.eq.5).or.(select.eq.1.and.itask.eq.15)
     $     ) then
         ip(3)=-302
         return
      endif
      if (ieq.eq.0) then
        nch = ichmv_ch(ibuf,nchar+1,'/')
        nch = ichmv(ibuf,nch,ltpnum(1,indxtp),1,8)
        nch = mcoma(ibuf,nch)
        nch = ichmv(ibuf,nch,ltpchk(1,indxtp),1,4)
        call fs_get_vacsw(vacsw,indxtp)
        if(vacsw(indxtp).eq.1) then
           nch = mcoma(ibuf,nch)
           call fs_get_thin(thin,indxtp)
           if(thin(indxtp).eq.1) then
              nch=ichmv_ch(ibuf,nch,'thin')
           else if (thin(indxtp).eq.0) then
              nch=ichmv_ch(ibuf,nch,'thick')
           endif
        endif
        iclass = 0
        call put_buf(iclass,ibuf,-nch+1,'fs','  ')
        ip(1) = iclass
        ip(2) = 1
        return
      endif
C
C     3. Read the first parameter, the tape number (not necessarily numeric).
C
      ich = 1+ieq
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).eq.'*'.or.cjchar(parm,1).eq.',') then
        ip(3) = -101
        return                              !  missing or blank tape number
      endif
      length = ich-ieq-2
      if (length.ne.8 .and. length.ne.10) then
        ip(3) = -201
        return                              !  wrong length
      endif
      idumm1 = ichmv(lnum,1,ibuf,1+ieq,8)            !  put tape # in lnum
C
C     4. The bar code reading program, RWAND, sends a ten-character tape #
C     whose last byte is a checksum.  Operators enter eight-character tape
C     numbers followed by four-character hash codes called check labels.
C
      if (length.eq.10) then                !  label from bar code reader
        isum = 30
        do i=1,8
          isum = isum + iscns(lbarco,1,43,lnum,i,1)
        enddo
        if (mod(isum,43).ne.iscns(lbarco,1,43,ibuf,10+ieq,1)-1) then
          ip(3) = -202
          return
        endif
        call gtprm(ibuf,ich,nchar,0,parm,ierr) !ignore if present
      else                                  !  operator typed in tape #.
        call gtprm(ibuf,ich,nchar,0,parm,ierr)
        if (cjchar(parm,1).eq.'*'.or.cjchar(parm,1).eq.',') then
          ip(3) = -102
          return                      !  missing or blank check label
        endif
C       Change any O's in the check label to 0's
        do i=1,4
          if (index('Oo',cjchar(parm,i)).ne.0)
     &         call char2hol('0',parm,i,i)
        enddo
      endif
C
C     5. Generate check label.  If the operator typed the parameters,
C     compare this check label against the one the operator typed.  Change
C     O's to zeroes in the tape number whether label was typed or scanned.
C
      do i=1,8
        if (index('Oo',cjchar(lnum,i)).ne.0) call char2hol('0',lnum,i,i)
      enddo
      call upper(lnum,1,8)
      icode = ihash(lnum,1,8)
      lchk(2) = ih22a(jchar(icode,1))
      lchk(1) = ih22a(jchar(icode,2))
      call upper(lchk,1,4)
      call upper(parm,1,4)
      if (length.eq.8 .and. ichcm(lchk,1,parm,1,4).ne.0) then
        ip(3) = -202
        return                              !  label check failed.
      endif
C
C  check for a thick/thin override
C
      call fs_get_vacsw(vacsw,indxtp)
      ist=ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).eq.',') then
         if(vacsw(indxtp).eq.1) then
            iovthin=-1
         endif
      else if(vacsw(indxtp).ne.1) then
         ip(3)=-303
      else if(ichcm_ch(ibuf,ist,'thin').eq.0) then
         iovthin=1
      else if(ichcm_ch(ibuf,ist,'thick').eq.0) then
         iovthin=0
      else
         ip(3)=-203
         return
      endif
      if(vacsw(indxtp).ne.1) goto 800

      if(ichcm_ch(lnum,1,'VLBA'    ).eq.0 .or.
     &   ichcm_ch(lnum,1,'NASA'    ).eq.0 .or.
     &   ichcm_ch(lnum,1,'USN01'   ).eq.0 .or.
     &   ichcm_ch(lnum,1,'SVLB'    ).eq.0 .or.
     &   ichcm_ch(lnum,1,'3MTHN'   ).eq.0 .or.
     &   ichcm_ch(lnum,1,'0VLB'    ).eq.0 .or.
     &   ichcm_ch(lnum,1,'JIVE'    ).eq.0 .or.
     &   ichcm_ch(lnum,1,'EVNT'    ).eq.0 .or.
     &   ichcm_ch(lnum,1,'GIFT00'  ).eq.0 .or.
     &   ichcm_ch(lnum,1,'HST'     ).eq.0 .or.
     &   ichcm_ch(lnum,1,'UNQU'    ).eq.0 .or.
     &   ichcm_ch(lnum,1,'SAMP'    ).eq.0 .or.
     &   ichcm_ch(lnum,1,'DSCP'    ).eq.0 .or.
     &   ichcm_ch(lnum,1,'MPIT'    ).eq.0 .or.
     &   ichcm_ch(lnum,1,'THNINT'  ).eq.0 .or.
     &   ichcm_ch(lnum,1,'ISAS'    ).eq.0 .or.
     &   ichcm_ch(lnum,1,'NAIC'    ).eq.0 .or.
     &   ichcm_ch(lnum,1,'CMVA'    ).eq.0
     &     ) then
         thin(indxtp)=1
      else
         thin(indxtp)=0
      endif
C
      if(iovthin.ne.-1) thin(indxtp)=iovthin
      call fs_set_thin(thin,indxtp)
C
C     6. Now plant the new tape number and check label in COMMON.
C
 800  continue
      idumm1 = ichmv(ltpnum(1,indxtp),1,lnum,1,8)
      idumm1 = ichmv(ltpchk(1,indxtp),1,lchk,1,4)
C
C
C     7. Schedule PRLAB to print tape label if next parameter is P.
C        Queue schedule, no wait.
C
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (ichcm_ch(iparm,1,'p ').eq.0) then
C       Find out whether PRLAB is RPed already; if not, RP it
c       if (ipgst(6hprlab ).eq.-1) then
c       endif
        if (ip(3).ne.-301) 
     .     call run_prog('prlab','nowait',lu,2,idum,idum,idum)
      endif
c
c issue mounterX if this is dual drive system and this was "mount"
c
      if(itask.eq.5) then
         inext1=ichmv_ch(ibuf2,1,'mounter1')
         call copin(ibuf2,inext1-1)
         knewtape(1)=.true.
         call fs_set_knewtape(knewtape,1)
         return
      else if(itask.eq.15) then
         inext1=ichmv_ch(ibuf2,1,'mounter2')
         call copin(ibuf2,inext1-1)
         knewtape(2)=.true.
         call fs_set_knewtape(knewtape,2)
         return
      endif
c
c for non-mount commands:
c
      khalt=.false.       !  undo boss's halt so the schedule can proceed.
      call fs_set_khalt(khalt)
      return
      end
