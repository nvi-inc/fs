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
      subroutine proc_ifd(cproc_ifd,icode,kpcal)
! write out IFD and LO procedures
      implicit none  !2020Jun15 JMGipson automatically inserted.
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'

      include 'bbc_freq.ftni'
      include 'drcom.ftni'

!History
! 2020-05-08 JMG Got rid of filter output for DBBC3
! 2020-12-30 JMG Support for DBBC3
! 2016-01-19 JMG Modified to handle DBBC_PFB which can have several DBBs with same number.
! 2013-07-11 JMG Added "if_targets"
! 2012-09-12 JMG Checking of valid IFs made case independnent.
! 2012-09-05 JMG Changes to support DBBC.
!                fvc,fvc_lo, fvc_hi put in bbc_freq.ftni
! 2007-07-09 JMG Split off from procs.

! passed
      character*(*) cproc_ifd   !name of procedure.
      integer icode     ! Code
      logical kpcal     ! do pcal

! functions
      integer ichmv_ch  !lnfch

C    for VLBA:  IFDAB=0,0,nor,nor
C               IFDCD=0,0,nor,nor
C    for Mk3:   ifd=atn1,atn2,nor/alt,nor/alt
C               ifd=,,nor/alt,nor/alt <<<<<< as of 010207 default atn is null
C               if3=atn3,out,1,1 (out for narrow)
C               if3=atn3,in,2,2 (in for WB)
C               if3=,out,1,1 <<<<<<<< as of 010207 default atn is null
C               if3=,in,1or2=LorHforVC3,1or2=LorHforVC10
C               if3=,out,1or2,1or2
C               patch=lo1,...
C               patch=lo2,...
C               patch=lo3,...
C    for K4-2:  patch=lo1,a1,a2,...
C               patch=lo2,b1,b2,...
C               lo=same as Mk3
C    for K4-1:  patch=lo1,1-4,5-8,etc.
C    for LBA:   lo=same as Mk3 ( but allow up to 4 IFs)
!    for DBBC   ifX=input,agc,filter#,target  where X=A,B,C,D and input=1,2,3,4, target=1-65535
!    for DBBC3  ifX=input,agc,target 
!

C Later: add a check of patching to determine how the IF3 switches should really be set.
C         if (VC3  is LOW) switch 1 = 1, else 2
C         if (VC11 is LOW) switch 2 = 1, else 2

! local
      integer ifd(8)            !ifd(j)<>0 indicates we have IF
      integer ibd(8)            !ib(j)<>   is one of the BBCs the IF connects to.
                                !This is used because we can find the filter from the BBC#.

      character*8 lvalid_if     !Valid IF characters
      integer ivc3_patch        !VC3,VC10 patch hi or lo?
      integer ivc10_patch
      integer itemp
      integer ib                !ibbc#
      integer ichan             !loop over channels
      integer ic                !channel index
      integer iv                !channel#
      integer ilo               !LO index
      logical kfound_if         !true if we have  a valid IF 
      integer j                 !loop index
      integer nch               !character counter
      character*2  cif          !Holds IF name.
      character*1 ch1           !Single character
      real*8  rlo_dif31         !LO freq3-lo freq1 (if both definied)
      real*8  tol               !tolerance: How close to zero do we need to be.
      logical kdone_bbc(max_bbc)
      integer max_ifd_use       

      tol=0.00001
      call proc_write_define(lu_outfile,luscn,cproc_ifd)

! Initialize IFDs to not used.
      do j=1,8
       ifd(j)=0
       ibd(j) =0
      end do

      do ib=1,max_bbc
         kdone_bbc(ib)=.false.
      enddo

      if(cstrack_cap .eq. "DBBC3_DDC") then
        lvalid_if="ABCDEFGH"
      else if (kbbc .or. kdbbc_rack) then
        lvalid_if="ABCD"
      else
        lvalid_if="1234"
      endif
!
      kfound_if = .false.
      do ichan=1,nchan(istn,icode) ! which IFs are in use
        ic=invcx(ichan,istn,icode) ! channel number
        ib=ibbcx(ic,istn,icode) ! BBC number
        if(.false.) then
          call write_return_if_needed(luscn,kwrite_return)
          write(luscn,'(3i4,a,1x,a)') ichan,  ic, ib," Cifinp-->",
     >    cifinp(ic,istn,icode)
        endif

! Note: For PFB can have several BBCs with the same number...
        if(freqrf(ic,istn,icode) .gt. 0 .and.
     &    (.not.kdone_bbc(ib) .or.
     &      cstrack_cap(1:8) .eq."DBBC_PFB")) then

          ch1=cifinp(ic,istn,icode)(1:1)

          call capitalize(ch1)
          j=index(lvalid_if,ch1)
          if(j .ge. 1) then
            kfound_if = .true. 
            if(ifd(j) .eq. 0) ifd(j)=ic
            if(ibbc_present(ib,istn,icode) .gt. 0) ibd(j)=ib
          endif
        endif

        kdone_bbc(ib)=.true.
      enddo ! which IFs are in use
    
      if(.not. kfound_if) then
        write(*,*)
        write(*,*) "ERROR (proc_ifd):  No valid LO inputs in schedule!"
        return 
      endif

      if(kdbbc_rack .or. cstrack_cap .eq. "DBBC3_DDC") then
        if(cstrack_cap .eq. "DBBC3_DDC") then
           max_ifd_use=max_dbbc3_ifd
        else
           max_ifd_use=max_dbbc_ifd
        endif      
        do j=1,max_ifd_use      !upto 4 IFs
          iv=ifd(j)
          if(ifd(j) .ne. 0) then
            cif=cifinp(iv,istn,icode)
            if(cstrack_cap .eq. "DBBC3_DDC") then
! Leave out filter for DBBC3_DDC
              write(cbuf,'("if",a1,"=",a1,",agc")')
     >          cif(1:1), cif(2:2)
            else if(ibbc_filter(ibd(j)) .ge. 0) then 
              write(cbuf,'("if",a1,"=",a1,",agc,",i1)')
     >          cif(1:1), cif(2:2), ibbc_filter(ibd(j)) 
            else
              write(cbuf,'("if",a1,"=",a1,",agc,")')
     >          cif(1:1), cif(2:2)
            endif 
            if(idbbc_if_targets(j) .ge. 0) then
              write(cbuf(15:20),'(",",i5)') idbbc_if_targets(j)
            endif
            call drudg_write(lu_outfile,cbuf)    
          endif
        end do
        write(lu_outfile,'(a)') 'lo='
        do ilo=1,max_ifd_use
          iv=ifd(ilo)
          if(iv .ne. 0) then
!            write(*,*) "ilo ", ilo, " iv ", iv
            call proc_lo(iv,icode,lvalid_if(ilo:ilo))
           endif ! this LO in use
        end do
!        writE(*,*) "freq: ", (freqlo(j,istn,1), j=1,16)      

      else if(kmracks) then ! mk3/4/5 IFD
        cbuf="ifd=,"
        nch=6
        do j=1,2
          if (ifd(j).ne.0) then ! IF is in use
            IF (cifinp(ifd(j),istn,ICODE)(2:2).eq. 'N') then
              cbuf(nch:nch+4)=",nor"
            ELSE ! must be 'A'
              cbuf(nch:nch+4)=",alt"
            ENDIF
            nch=nch+4
          else
            cbuf(nch:nch)=","
            nch=nch+1
            if(j .eq. 2) cbuf(nch:nch)=","   !add extra "," for backward compatibility.
          endif
        end do
        write(lu_outfile,'(a)') cbuf(1:nch)
C  First determine the patching for VC3 and VC10.
        ivc3_patch =2       !default values
        ivc10_patch=2
        DO ic = 1,nchan(istn,icode)
          iv=invcx(ic,istn,icode) ! channel number
          ib=ibbcx(iv,istn,icode) ! VC number
          itemp=1
          if(ib .eq. 3 .or.ib .eq. 10) then
            if(kgeo) then
              if(fvc_hi(ib) .lt. 230.0) then
!               itemp=1
              else if(fvc_lo(ib) .gt. 210.0) then
                itemp=2
              else if((fvc_lo(ib)+fvc_hi(ib))/2. .lt. 220.0) then
!                itemp=1
              else
                itemp=2
              endif
            else
              if(fvc(ib).gt.210.0) itemp=2
            endif
            if(ib .eq. 3) then
              ivc3_patch=itemp
            else
              ivc10_patch=itemp
            endif
          endif
        enddo
      endif

! Mk3/4, K4  and LBA
! Put out IF3 if it exits
      if(kvc .or. klrack) then
        if(ifd(1) .ne. 0 .and. ifd(3) .ne. 0) then
          rlo_dif31=freqlo(ifd(3),istn,icode)-freqlo(ifd(1),istn,icode)
          if(rlo_dif31 .eq. 0.d0 .or. abs(rlo_dif31-500.1).lt.tol) then

! Make a string that looks something like:
!          if3=,in,ivc3_patch,ivc_10_path,,,on
            cbuf="if3=,in,"    !default case.
            nch=9
! check " if3=,out" possibility. Different for VEX and non-vex.
            if(kvex.and.cifinp(ifd(3),istn,ICODE)(2:2).eq. 'O' .or.
     >         .not.kvex  .and. rlo_dif31 .eq. 0.d0) then
           cbuf="if3=,out,"
           nch=10
          endif
          write(cbuf(nch:nch+5),'(i1,",",i1,",,,")')
     >         ivc3_patch,ivc10_patch
           nch=nch+6
C              Add phase cal on/off info as 7th parameter.
          if (kpcal) then ! on
            nch=ichmv_ch(ibuf,nch,'on')
          else ! off
            nch=ichmv_ch(ibuf,nch,'off')
          endif ! value/off
          write(lu_outfile,'(a)') cbuf(1:nch)
          endif
        endif ! we know/don't know about IF3
      endif

C LO command for Mk3/4 and K4 and LBA
C           First reset all
      if(kvc .or.klrack) then
        write(lu_outfile,'(a)') "lo="
        do ilo=1,4 ! up to 4 LOs
          iv=ifd(ilo)
          if(iv .ne. 0) then
            call proc_lo(iv,icode, lvalid_if(ilo:ilo))
           endif ! this LO in use
        enddo ! up to 4 LOs
      endif

C
C PATCH command for Mk3/4 and K4
C           First reset all
      if (kvc) then
         call proc_patch(icode,ifd)
      endif ! m3rack IFD, LO, PATCH commands

      if (kbbc) then ! vlba IFD, LO commands
C IFDAB, IFDCD commands
         if(ifd(1)+ifd(2) .ne. 0)
     >        write(lu_outfile,'(a)') 'ifdab=0,0,nor,nor'
          if(ifd(3)+ifd(4) .ne. 0)
     >       write(lu_outfile,'(a)')  'ifdcd=0,0,nor,nor'

C LO command for VLBA
          write(lu_outfile,'(a)') 'lo='
          do ilo=1,4
           iv=ifd(ilo)
           if(iv .ne. 0) then
             call proc_lo(iv,icode,lvalid_if(ilo:ilo))
            endif ! this LO in use
          end do
        endif
        if(klo_config) then
          write(lu_outfile,'(a)') "lo_config"
        endif


        write(lu_outfile,"(a)") 'enddef'
        return
        end

