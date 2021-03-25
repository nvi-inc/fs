*
* Copyright (c) 2021 NVI, Inc.
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
      subroutine proc_core3h(cproc_core8h,icode)
      implicit none
! Generate the core3h procs...
! A large part of this is generating the bitmasks

      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
      include 'drcom.ftni'

! functions
      integer itras
! passed
      character*(*) cproc_core8h
      integer icode
! function
!      integer iwhere_in_string_list


! History
! 2021-02-12 JMG  First debugged version 

! DBBC3_DDCs 128 BBCs.  
! The BBCs are tied to 8 boards, with each board having 16 BBCs.  The order is
!           Mask2   Mask1
! Board01:  65-72,  1-8
! Board02:  73-80,  9-16
! Board03:  81-99,  17-24
!..
! Board08: 121-128, 57-67
! Each BBC is tied to upto 4 channel: LM,LS,UM,US.
! If we are recording a channel want to turn on the corresponding bit.
! Total number of bits in a mask is 4*8=32

! Our approach is simple.
!  We start with one mask for each BBC and set the appropriate bitrs.
!  Then we use this to set the bits in ibrdmask.
      integer*4 imask(8,2) 
      integer  ibbc_mask(max_bbc)
      character*5 lsked_csb(max_chan*2)  !for debugging purposes. 
      integer*4 imask_temp
      integer ibrd                   !which board 
      integer ihalf
      integer ibbc_tmp
      integer num_shift  
      integer ipass               !which pass. hardcoded to 1
      integer ic                  !counter of channels.
      
      integer isb, isb_out        !sideband
      integer ihd                 !counter over headstacks. 
      integer ibit                !counter over bits
      integer ibbc 
      integer num_tracks
      logical kdebug 
      integer iset 
      character*1 lul(2)            !ASCII "U","L"
      character*1 lsm(2)            !ASCII "S","M"
      character*12 lsamprate
      double precision dtemp  
      integer ierr
      integer nch 
     
      data lul/"U","L"/
      data lsm/"S","M"/
      kdebug=.false. 
!      kdebug=.true. 

        do ibrd=1,8
        imask(ibrd,1)=0
        imask(ibrd,2)=0
      end do 
      do ibbc=1,max_bbc
       ibbc_mask(ibbc)=0
      end do 

      ipass=1
!      write(*,*)
      if(kdebug) then
        write(*,*) " " 
        write(*,'(a)')
     &   "  chan bbc   sb   sbo   bit pass stn code  CSB    MSK"

      endif
    
! Go through all of the channels. 
!    if(kdebug) write(*,*) "ic ibbc isb ibit" 
      num_tracks=0
      do ic=1,nchan(istn,icode)
         ibbc=ibbcx(ic,istn,icode)   !this is the BBC#
         do isb=1,2
            isb_out=isb
            if(abs(freqrf(ic,istn,icode)).lt.freqlo(ic,istn,icode)) then
              isb_out=3-isb    !swap the sidebands
            endif ! reverse sidebands
!            do ihd=1,max_headstack
            do ihd=1,1
            do ibit=1,2 
              if (itras(isb,ibit,ihd,ic,ipass,istn,icode).ne.-99) then         !number of tracks set.
                num_tracks=num_tracks+1

!                 if(kdebug) write(*,'(4i4)') ic, ibbc,  isb, ibit 
! order of bits Most to least is LSBM, LSBS, USBM, USBS
! isb_out=1 is USB. 
!                if(isb_out .eq. 1 .and. ibit .eq. 1) iset=1 
!                if(isb_out .eq. 1 .and. ibit .eq. 2) iset=2
!                if(isb_out .eq. 2 .and. ibit .eq. 1) iset=4
!                if(isb_out .eq. 2 .and. ibit .eq. 2) iset=8 
                if(isb_out .eq. 1) then
                    iset=ibit
                else
                    iset=ibit*4
                endif 
                ibbc_mask(ibbc)=ibbc_mask(ibbc)+iset    
!                write(*,*) ibbc, iset, ibbc_mask(ibbc)              

                write(lsked_csb(num_tracks),'(i3.3,a1,a1)')
     >            ibbc, lul(isb_out), lsm(ibit)
                if(kdebug) then
                  write(*,'(8i5,2x,a," | ",z2.2)')  ic,ibbc,
     >                isb,isb_out,ibit,ipass,istn,icode,
     >                lsked_csb(num_tracks), 
     >                ibbc_mask(ibbc)
                endif
              endif
            enddo
          enddo
        enddo
      enddo
! Now have all of the BBCs. Set the board_masks
      if(kdebug) then
         write(*,*) "BBC MSK"
      endif 
      do ibbc=1,max_bbc
        if(kdebug) then
           write(*,'(i4,1x,z2.2)') ibbc, ibbc_mask(ibbc) 
        endif  
        if(ibbc_mask(ibbc) .ne. 0) then 

          ibbc_tmp=ibbc
          ihalf=1 
          if(ibbc .gt. 64) then
            ihalf=2
            ibbc_tmp=ibbc_tmp-64
          endif
          ibrd=1
         do while(ibbc_tmp .gt. 8)
           ibbc_tmp=ibbc_tmp-8
           ibrd=ibrd+1
         end do 
    
! Example.  IB=35.   Ihalf=1, ibrd=4, ibbc_tmp=3 
          num_shift=(ibbc_tmp-1)*4 
!          write(*,*) "Num_shift ", num_shift 
          imask_temp=ishft(ibbc_mask(ibbc),num_shift)  
          imask(ibrd,ihalf)=ior(imask(ibrd,ihalf),imask_temp)
!          write(*,'("BBC board half ",3i4)') ibbc, ibrd, ihalf
!          write(*,'("Mask ",2(1x,z32))')imask_temp, imask(ibrd,ihalf) 

        endif 
      end do 
! Now output command the procedure
      call proc_write_define(lu_outfile, luscn,cproc_core8h)

      write(lu_outfile,'(a)') "core3h_mode0=begin,$"

      dtemp=samprate(istn,icode)
      call double_2_string(dtemp,'(f11.4)', lsamprate,nch,ierr) 
      do ibrd =1,8
        if(imask(ibrd,1) .ne. 0 .or. imask(ibrd,2) .ne. 0) then 
          if(imask(ibrd,2) .eq. 0) then 
! Output null for imask(ibrd,2) in this case. 
             write(cbuf,
     &       '("core3h_mode",i1,"=,",1("0x",z8.8,","),",",a,",$")') 
     &       ibrd, imask(ibrd,1),  lsamprate(1:nch)
          else
             write(cbuf,
     &       '("core3h_mode",i1,"=",2("0x",z8.8,","),",",a,",$")') 
     &       ibrd,imask(ibrd,2),imask(ibrd,1),lsamprate(1:nch) 
          endif 
!         write(*,*) idec, samprate(istn,icode) 


         call drudg_write(lu_outfile,cbuf) 
        endif
      end do
      write(lu_outfile,'(a)') "core3h_mode0=end,$"
      write(lu_outfile,"(a)") 'enddef'

      return
      end 

        
        







