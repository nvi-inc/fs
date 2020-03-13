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
      subroutine ena(ip,itask)
C  track enable control c#870115:04:39#
C
C 1.1.   ENA controls the track enable function
C
C     INPUT VARIABLES
      dimension ip(1)
C        IP(1)  - class number of input parameter buffer.
C
C     OUTPUT VARIABLES:
C        IP(1) - CLASS RETURNED
C        IP(2) - # RECORDS
C        IP(3) - ERROR
C        IP(4) - who we are
C
C 2.2.   COMMON BLOCKS USED
      include '../include/fscom.i'
C
C     CALLED SUBROUTINES: GTPRM,ENDIS
C 
C 3.  LOCAL VARIABLES 
C        NCHAR  - number of characters in buffer
C        IMMODE - mode for MAT
C        ICH    - character counter 
      integer*2 ibuf(50)
C               - class buffer
      dimension ig1(4)
C               - first track in group
C        ILEN   - length of IBUF, chars
      dimension iparm(2)
C               - parameters returned from GENARM
      dimension ireg(2)
      integer get_buf
C               - registers from EXEC calls
      dimension itrk(28)
C               - one word per track
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1))
C
      logical keven,kodd
      logical kena(2)
C
C 5.  INITIALIZED VARIABLES
      data ilen/100/
      data ig1/0,1,14,15/
C
C 6.  PROGRAMMER: NRV
C     LAST MODIFIED:  790320
C  WHO  WHEN    DESCRIPTION
C  GAG  910128  Added Write Electronics logic to change tracks according
C               to the variable WRHD_FS.
C  gag  920724  Added MK4 code.
C  nrv  921027  Changed stack0/1 to stack1/2
C
C     PROGRAM STRUCTURE
C
C  1. If we have a class buffer, then we are to enable tracks.
C     If no class buffer, we have been requested to read the enabled tracks.
C
      if( itask.eq.1) then
         indxtp=1
      else
         indxtp=2
      endif
c
      ichold = -99
      iclcm = ip(1)
      if (iclcm.eq.0) then
        ierr = -1
        goto 990
      end if
      call ifill_ch(ibuf,1,ilen,' ')
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2)
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0) goto 500
C                   If no parameters, go read device
      if (cjchar(ibuf,ieq+1).eq.'?') then
        ip(1) = 0
        ip(4) = o'77'
        call endis(ip,iclcm,indxtp)
        return
      end if
C
      if (ichcm(ibuf,ieq+1,ltsrs,1,ilents).eq.0) goto 600
      if (ichcm(ibuf,ieq+1,lalrm,1,ilenal).eq.0) goto 700
C
C
C  2. Step through buffer getting each parameter and decoding it.
C     Command from user has these parameters:
C                   ENABLE=<track1,...trackn>
C     where
C           <track1...> = list of tracks, or G<n> where <n> is group number
C
C
      ich = ieq+1
C
C  The enable command for the Mark IV formatter only sets
C  a common logical variable to indicate which head stacks
C  are enabled. The options for the command are: stack1 and/or stack2
C  or null.
C
      call fs_get_drive(drive)
      if (MK4.eq.drive(indxtp)) then
        kena(1)=.false.
        kena(2)=.false.
        if (ich.lt.nchar) then
          call fdfld(ibuf,ich,nchar,ic1,ic2)
          if (ic1.gt.0) then
            if (ichcm_ch(ibuf,ic1,'stack2').eq.0) then
              kena(2)= .true.
            else if (ichcm_ch(ibuf,ic1,'s2').eq.0) then
              kena(2)= .true.
            else if (ichcm_ch(ibuf,ic1,'stack1').eq.0) then
              kena(1)= .true.
            else if (ichcm_ch(ibuf,ic1,'s1').eq.0) then
              kena(1)= .true.
            else if (ichcm_ch(ibuf,ic1,'null').eq.0) then
              kena(1)= .false.
              kena(2)= .false.
            else
              ierr= -103
              goto 990
            endif
          endif
          call fdfld(ibuf,ich,nchar,ic1,ic2)
          if (ic1.gt.0) then
            if (ichcm_ch(ibuf,ic1,'stack2').eq.0) then
              kena(2)= .true.
            else if (ichcm_ch(ibuf,ic1,'s2').eq.0) then
              kena(2)= .true.
            else if (ichcm_ch(ibuf,ic1,'stack1').eq.0) then
              kena(1)= .true.
            else if (ichcm_ch(ibuf,ic1,'s1').eq.0) then
              kena(1)= .true.
            else
              ierr= -103
              goto 990
            endif
          endif
        endif
        call fs_get_icheck(icheck(18+indxtp-1),18+indxtp-1)
        ichold = icheck(18+indxtp-1)
        icheck(18+indxtp-1)=0
        call fs_set_icheck(icheck(18+indxtp-1),18+indxtp-1)
C     Turn off checking while we set up the module
        kenastk(1,indxtp)=kena(1)
        kenastk(2,indxtp)=kena(2)
        call fs_set_kenastk(kenastk,indxtp)
        call fs_get_ienatp(ienatp,indxtp)
        ibuf(1)=0
        if(indxtp.eq.1) then
           call char2hol('t1',ibuf(2),1,2)
        else
           call char2hol('t2',ibuf(2),1,2)
        endif
        call en2ma4(ibuf(3),ienatp(indxtp),kenastk(1,indxtp))
        iclass=0
        call put_buf(iclass,ibuf,-13,'fs','  ')
        nrec = 1
        goto 800
      endif
C
C  2.1 TRACKS, PARAMETERS 2
C
      do i=1,28
        itrk(i) = 0
      end do
C                   Disable all tracks to start
C                   Leave general enable as is
      ntrk=0
      do i=1,28
        call gtprm(ibuf,ich,nchar,0,parm,ierr)
        if (cjchar(parm,1).eq.'*') then
          ierr = -102
          goto 990
        end if
        if (cjchar(parm,1).eq.',') goto 300
C                   We are done when there are no more
        if (cjchar(iparm,1).ge.'0'.and.cjchar(iparm,1).le.'9') then
C                   If parameter is a number
          nc = 1
          if (cjchar(iparm,2).ne.' ') nc = 2
C                   Number of characters to decode from ASCII to binary
          it = ias2b(iparm,1,nc)
          if (it.le.0.or.it.gt.28) then
            ierr = -200-i
            goto 990
          end if
C                   Check for in range
          itrk(it) = 1
          ntrk=ntrk+1
        else if (cjchar(iparm,1).ne.'g') then
          ierr = -200-i
          goto 990
C                   If not a "G", illegal
        else
          ig = ias2b(iparm,2,1)
          if (ig.lt.1.or.ig.gt.4) then
            ierr = -200-i
            goto 990
          end if
          do j=1,14,2
            itrk(j+ig1(ig)) = 1
            ntrk=ntrk+1
          end do
        end if
      end do
C
C
C     3. Format the buffer for the controller.
C                  mmTP%tttttttt
C     where each "t" has 3 or 4 bits set by enabled tracks.
C
300   continue
      ibuf(1) = 0
C*************WE ARE NOT TURNING ON THE GENERAL ENABLE BIT WITH THIS COMMAND
C*************ONLY THE REQUESTED TRACKS ARE SET UP.
C     IF (NTRK.GT.0) IENA = 1
      if(indxtp.eq.1) then
         call char2hol('t1',ibuf(2),1,2)
      else
         call char2hol('t2',ibuf(2),1,2)
      endif
C
C
C  4.0  Now plant these values into COMMON.  Send to MATCN.
C
      call fs_get_icheck(icheck(18+indxtp-1),18+indxtp-1)
      ichold = icheck(18+indxtp-1)
      icheck(18+indxtp-1)=0
      call fs_set_icheck(icheck(18+indxtp-1),18+indxtp-1)
C                   Turn off checking while we set up the module
  
C  CHECK FOR EVEN AND ODD TRACKS WITH EVEN OR ODD ELECTRONICS
 
      keven=.false.
      kodd=.false.
      call fs_get_wrhd_fs(wrhd_fs,indxtp)
      do i=1,28
        if (itrk(i).eq.1) then
          if (mod(i,2).eq.0) keven=.true.
          if (mod(i,2).ne.0) kodd=.true.
        end if
      end do
C
      do i=1,28
        itrkenus_fs(i,indxtp)=itrk(i)
        itrk(i)=0
      end do
      if(wrhd_fs(indxtp).lt.0.or.wrhd_fs(indxtp).gt.2) then
        ierr = -207
        goto 990
      endif
      do i=1,28
        if(itrkenus_fs(i,indxtp).ne.0) then
          ia=i
          if (kodd.and.keven) then  !we can't map in this case
             continue                    
          else if (wrhd_fs(indxtp).eq.2) then           !even
            if (mod(i,2).ne.0) ia=ia+1
          else if (wrhd_fs(indxtp).eq.1) then      !odd
            if (mod(i,2).eq.0) ia=ia-1
          end if
          itrk(ia)=1
        endif
      end do
      do i = 1,28
        itrken(i,indxtp) = itrk(i)
      end do
      call fs_get_ienatp(ienatp,indxtp)
      call en2ma(ibuf(3),ienatp(indxtp),itrken(1,indxtp),ldummy)
      idumm1 = ichmv(ltrken,1,ibuf,6,8)
      ia = and(ia2hx(ltrken,1),7)
      idumm1 = ichmv(ltrken,1,ihx2a(ia),2,1)
C
      iclass = 0
      call put_buf(iclass,ibuf,-13,'fs','  ')
      nrec = 1
      goto 800
C
C
C     5.  This is the read device section.
C     Fill up one class buffers, requesting % data (mode -2).
C 
500   continue 
      if(indxtp.eq.1) then
         call char2hol('t1',ibuf(2),1,2)
      else
         call char2hol('t2',ibuf(2),1,2)
      endif
      iclass = 0
      ibuf(1) = -2
      call put_buf(iclass,ibuf,-4,'fs','  ') 
      nrec = 1
      goto 800
C 
C 
C 
C     6. This is the test/reset device section. 
C 
600   continue 
      ibuf(1) = 6 
      if(indxtp.eq.1) then
         call char2hol('t1',ibuf(2),1,2)
      else
         call char2hol('t2',ibuf(2),1,2)
      endif
      iclass=0
      call put_buf(iclass,ibuf,-4,'fs','  ') 
      nrec = 1
      goto 800
C 
C
C     7. This is the alarm query and reset request.
C
700   continue
      ibuf(1) = 7
      if(indxtp.eq.1) then
         call char2hol('t1',ibuf(2),1,2)
      else
         call char2hol('t2',ibuf(2),1,2)
      endif
      iclass=0
      call put_buf(iclass,ibuf,-4,'fs','  ')
      nrec = 1
      goto 800
C
C
C     8. All MATCN requests are scheduled here, and then ENDIS called.
C
800   continue
      call run_matcn(iclass,nrec)
      call rmpar(ip)
      if(ichold.ne.-99) then
        icheck(18+indxtp-1) = ichold
        call fs_set_icheck(icheck(18+indxtp-1),18+indxtp-1)
      endif
      if (ichold.ge.0) then
         icheck(18+indxtp-1)=mod(ichold,1000)+1
         call fs_set_icheck(icheck(18+indxtp-1),18+indxtp-1)
         kentp_fs(indxtp)=.true.
      endif
      call endis(ip,iclcm,indxtp)
      return
C
990   continue 
      ip(1) = 0
      ip(2) = 0
      ip(3) = ierr
      call char2hol('qe',ip(4),1,2)
      return
      end
