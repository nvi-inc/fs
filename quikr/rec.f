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
      subroutine rec(ip,itask)
C  Mark III/IV rec command tape c#870115:04:41#
C 
C     This routine handles the "rec" tape command.
C 
      dimension ip(1) 
      dimension ireg(2) 
      integer get_buf
C
      include '../include/fscom.i'
C
      integer*2 ibuf(20)
      character cjchar
      equivalence (ireg(1),reg)
      data ilen/40/
C
C  WHO  WHEN    DESCRIPTION
C
C     1. First pick up the class buffer with the command in it.
C     Find out whether this is a monitor or setting command by
C     checking for the "=" sign.
C
      if( itask.eq.7) then
         indxtp=1
      else
         indxtp=2
      endif
      ichold = -99
      iclcm = ip(1)
      if (iclcm.ne.0) goto 110
      ierr = -1
      goto 990
110   ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2)
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0) then
         ierr=-504
         goto 990
      endif
C 
C 
C     2. Step through buffer getting each parameter and decoding it.
C     Command from user has these parameters: 
C 
C                   rec=<load/novac>
C 
C     Choices are <load/novac>: LOAD or NOVAC, no default
C                               NOVAC is only allowed for vacuum switching M4s
C 
C 
C     2.1 DIRECTION, PARAMETER 1
C 
210   ich1 = ieq+1 
      ich = ich1 
      call gtprm(ibuf,ich1,nchar,0,parm,ierr) 
C                   Get the direction, ASCII
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 211 
      ierr = -401 
C                   No default for parameter
      goto 990
211   continue
      call gtfld(ibuf,ich,nchar,ic1,ic2)
      if(ichcm_ch(ibuf,ic1,'load').eq.0) then
         call fs_get_vacsw(vacsw,indxtp)
         call fs_get_thin(thin,indxtp)
         if(vacsw(indxtp).eq.1.and.thin(indxtp).ne.0.and.
     $        thin(indxtp).ne.1) then
            ierr=-502
            goto 990
         else if(vacsw(indxtp).eq.1) then
            if(thin(indxtp).eq.1) then
               vac4(indxtp)=1
            else
               vac4(indxtp)=2
            endif
            call fs_set_vac4(vac4,indxtp)
            thin(indxtp)=-1
            call fs_set_thin(thin,indxtp)
         endif
         call fs_get_icheck(icheck(18+indxtp-1),18+indxtp-1)
         ichold = icheck(18+indxtp-1) 
         icheck(18+indxtp-1) = 0
         ibuf(1) = 0
         nrec=0
         iclass=0
         if(indxtp.eq.1) then
            call char2hol('t1',ibuf(2),1,2)
         else
            call char2hol('t2',ibuf(2),1,2)
         endif
         if(vacsw(indxtp).eq.1) then
            call rpbr2ma4(ibuf(3),ibr4tap(indxtp),vac4(indxtp))
            call put_buf(iclass,ibuf,-13,'fs','  ')
            nrec=nrec+1
            call run_matcn(iclass,nrec)
            call rmpar(ip)
            if(ip(3).lt.0) return
            call clrcl(ip(1))
            call susp(2,3)
            iclass=0
            nrec=0
         endif
         call fs_get_idirtp(idirtp,indxtp)
         if(idirtp(indxtp).eq.-1) then
            idirtp(indxtp)=1
            call fs_set_idirtp(idirtp,indxtp)
         endif
         ispeed(indxtp)=1
         call fs_set_ispeed(ispeed,indxtp)
         call fs_get_lgen(lgen,indxtp)
         call mv2ma(ibuf(3),idirtp(indxtp),ispeed(indxtp),
     $        lgen(1,indxtp))
         kldtp_fs(indxtp)=.true.
         call put_buf(iclass,ibuf,-13,'fs','  ')
         nrec = nrec +1
      else if(ichcm_ch(ibuf,ic1,'novac').eq.0) then
         call fs_get_drive(drive)
         call fs_get_vacsw(vacsw,indxtp)
         if(drive(indxtp).ne.MK4.or.vacsw(indxtp).ne.1) then
            ierr=-503
            goto 990
         endif
         vac4(indxtp)=0
         call fs_set_vac4(vac4,indxtp)
         thin(indxtp)=-1
         call fs_set_thin(thin,indxtp)
         ibuf(indxtp) = 0
         nrec=0
         iclass=0
         if(indxtp.eq.1) then
            call char2hol('t1',ibuf(2),1,2)
         else
            call char2hol('t2',ibuf(2),1,2)
         endif
         call rpbr2ma4(ibuf(3),ibr4tap(indxtp),vac4(indxtp))
         call put_buf(iclass,ibuf,-13,'fs','  ')
         nrec=nrec+1
      else 
         ierr=-501
         goto 990
      endif
C
      call run_matcn(iclass,nrec)
      call rmpar(ip)
      call recds(ip,iclcm)
C
415   continue
      icheck(18+indxtp-1) = ichold
      call fs_set_icheck(icheck(18+indxtp-1),18+indxtp-1)
      if (ichold.ge.0) then
        icheck(18+indxtp-1) = mod(ichold,1000)+1
        call fs_set_icheck(icheck(18+indxtp-1),18+indxtp-1)
        kmvtp_fs(indxtp)=.true.
      endif
      return
C
C
C     5.  This is the read device section.
C     Fill up a class buffer, requesting ) data (mode -4).
C                                        % data (mode -2)
C
500   continue
      if(indxtp.eq.1) then
         call char2hol('t1',ibuf(2),1,2)
      else
         call char2hol('t2',ibuf(2),1,2)
      endif
      iclass = 0
      ibuf(1) = -4
      call put_buf(iclass,ibuf,-4,'fs','  ')
      ibuf(1) = -2
      call put_buf(iclass,ibuf,-4,'fs','  ')
C 
      call run_matcn(iclass,2) 
      call rmpar(ip)
      call recds(ip,iclcm)
      return
C 
990   ip(1) = 0 
      ip(2) = 0 
      ip(3) = ierr
      call char2hol('q<',ip(4),1,2)
      return
      end 
