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
      subroutine proc_form(icode,ipass,kroll,kman_roll,lform)
! 2013Sep19  JMGipson made sample rate station dependent
      implicit none  !2020Jun15 JMGipson automatically inserted.

C  FORM=m,r,fan,barrel,modu   (m=mode,r=rate=2*b)
C  For 8-BBC stations, use "M" for Mk3 modes
      include 'hardware.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
      include 'drcom.ftni'
! passed
      integer icode     !code index
      integer ipass     !pass #
      logical kroll     !roll turned on?
      logical kman_roll !manual barrel rolling?
! returned
      character*5 lform         !Mark4 or VLBA

! functions
      integer mcoma     !lnfch stuff
      integer ib2as
      integer ir2as
      integer ichmv_ch
      integer ichmv

      logical kCheckGrpOr
      integer trimlen

! local
      integer ig         	!group #
      integer nch         	!character counter
      logical kmodu


      kmodu =  .not.kvrack.and.cmodulation(istn,icode).eq.'on'

      cbuf="form=m"             !This is default form command. Modified below if necessary.
      nch=7
      lform="mark4"             !This is default.
      if((km5disk.or.km5A_piggy.or.KM5P_Piggy).and.
     >  .not.km3rack) then
        if(km3mode .or. km4form
     >             .or. cmfmt(istn,icode)(1:1) .eq. "m"
     >             .or. cmfmt(istn,icode)(1:1) .eq. "M") then
!           lform="mark4"
        else
          cbuf(6:6)=cmode(istn,icode)(1:1)      !replace mode letter.
          lform="vlba"
        endif
      else if (km3mode) then
 !       lform="mark4"
        if(klsblo.and.(kvrack .or. km4form)
     .    .or.k8bbc.and.(km3be.or.km3ac)) then
!          cbuf="form=m"     !not needed.
        elseif ((kvrack.or.km3rack.or.kk3fmk4rack).and.
     .          cmode(istn,icode)(1:1) .eq. 'E') THEN
C           MODE E = B ON ODD, C ON EVEN PASSES
          IF (MOD(IPASS,2).EQ.0) THEN
            cbuf="form=c"
          ELSE
            cbuf="form=b"
          ENDIF
        else ! not mode E or else Mk4 formatter
           cbuf(6:6)=cmode(istn,icode)(1:1)
        endif
      else ! not Mk3 mode
C     Use format from schedule, 'v' or 'm'
!        nch = ICHMV(IBUF,nch,lmFMT(1,istn,icode),1,1)
        if (kvrack) then ! add format to FORM command
          cbuf(6:6)="v"
        else if (km4form) then
!           nch = ICHMV_ch(IBUF,nch,'m')  not needed
        else
!write warning if not not vlba formatter or km4form
           write(luscn,'(/,a)') "proc_form - WARNING! Non-Mk3 "//
     >              "modes are not supported by your station equipment."
         endif ! add format to FORM command
       endif

C      Add group index for Mk4 formatter
C      ... but not for LSB case
       if (km4form .and.kpiggy_km3mode.and..not.klsblo.and.
     >       cmode(istn,icode) .ne. "A") then
           if (cmode(istn,icode).eq. "E") THEN ! add group
             if(kCheckGrpOr(itrk,2,16,1)) then
               ig=1
             else if(kCheckGrpOr(itrk,3,17,1)) then
               ig=2
             else if(kCheckGrpOr(itrk,18,32,1)) then
               ig=3
             else if(kCheckGrpOr(itrk,19,33,1)) then
               ig=4
             endif
             nch = nch+ib2as(ig,ibuf,nch,1) ! mode E group
           else ! add subpass number
             nch = nch+ib2as(ipass,ibuf,nch,1) ! mode B or C subpass
           endif
         endif ! add group or subpass
C      Add sample rate
         nch = MCOMA(IBUF,nch)
         nch = nch+IR2AS(samprate(istn,ICODE),IBUF,nch,6,3)
         if (.not.ks2rec(irec)) then ! non-S2 only
C      If no fan, or if fan is 1:1, skip it unless we have roll
C      or modulation.
         if ((ifan(istn,icode).ne.0.and.ifan(istn,icode).ne.1) .or.
     .      kroll.or.kmodu) then ! barrel or fan or modulation
           nch = MCOMA(IBUF,nch)
C        Put in fan only if non-zero
           if (ifan(istn,icode).ne.0) then ! fan
             nch = ichmv_ch(ibuf,nch,'1:')
             nch = nch+ib2as(ifan(istn,icode),ibuf,nch,1)
           endif
C        Roll parameter
           if (kroll) then
C          if (kvrack) then ! only for VLBA racks
C          Now ok for Mk4 formatters too
             if (kvrack.or. km4form) then
               nch = MCOMA(IBUF,nch)
               nch = ichmv(ibuf,nch,lbarrel(1,istn,icode),1,4)
               if (kvrack.and. .not. kman_roll) then
                 if (cbarrel(istn,icode) .eq. "8:1" .or.
     .               cbarrel(istn,icode) .eq. "16:1") then
                    continue
                  else ! add the :1 for VLBA racks
                    nch=trimlen(cbuf)
                    if(.not.km4form) nch=ichmv_ch(ibuf,nch+1,":1")
                  endif ! already there/add
                else if(km4form) then
                  nch=trimlen(cbuf)
                  if(cbuf(nch-1:nch) .eq. ":1") then
                    cbuf(nch-1:nch)=" "
                    nch=nch-2
                  endif
                  nch=nch+1
                endif
C           else if (kv4rack.or.km4rack.or.km4fmk4rack) then
C             write(luscn,9137)
C9137         format(/'PROCS05 - WARNING! Barrel roll is not',
C             ' supported for Mark IV formatters.')
             endif
           endif ! roll
           if (kmodu) then ! modulation
             nch=trimlen(cbuf)+1
             if (.not.kroll) then ! insert comma
               nch = MCOMA(IBUF,nch)
             endif ! insert comma
             nch = ichmv_ch(ibuf,nch,',on')
           endif ! modulation
         endif ! barrel or fan or modulation
       endif ! non-S2 only
       call lowercase_and_write(lu_outfile,cbuf)
       return
      end
