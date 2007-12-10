      subroutine proc_mk5b_tracks(lu_outfile,istn,icode)
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
! Write out Mark5B mode command.
! functions
      integer itras
! passed
      integer lu_outfile,istn,icode
! function
      integer iwhere_in_string_list

! History
!  2007Jul27 JMGipson.  First working version.

! local
      integer ipass
      integer isb,ibit,ihd,ic
      integer ib
      integer num_tracks
      integer nchan_rec
      integer it
      integer j
      integer*4 itemp
      integer*4 imask
      logical kgeo_mode
      integer idiv
      character*80 cbuf
      logical kfirst

      character*1 lul(2)            !ASCII "U","L"
      character*1 lsm(2)            !ASCII "S","M"
      integer max_csb
      parameter (max_csb=32)

      character*4 lsked_csb(max_csb)     !Channel,sideband,bit in sked file
! Only two valid cases:
! 1.) VLBA mode:  All tracks fit within first 8 channels.
!     Can be upper or lower, sign or sign&magnitude.
! 2.) GEO mode: Channels 1-14 USB and channels 1&8 LSB.

      character*4 lvlba_csb(max_csb),lgeo_csb(max_csb)
! The order determines what bit is set.
      data lvlba_csb/
     >   "01US","01UM","02US","02UM","03US","03UM","04US","04UM",
     >   "05US","05UM","06US","06UM","07US","07UM","08US","08UM",
     >   "01LS","01LM","02LS","02LM","03LS","03LM","04LS","04LM",
     >   "05LS","05LM","06LS","06LM","07LS","07LM","08LS","08LM"/

! The order determines what bit is set.
      data lgeo_csb/
     >   "01US","01UM","02US","02UM","03US","03UM","04US","04UM",
     >   "05US","05UM","06US","06UM","07US","07UM","08US","08UM",
     >   "01LS","01LM","08LS","08LM","09US","09UM","10US","10UM",
     >   "11US","11UM","12US","12UM","13US","13UM","14US","14UM"/

      data lul/"U","L"/
      data lsm/"S","M"/

      kfirst=.true.
! If we don't have a VSI4 formatter,
!   write out comments and command and exit.
      if(.not.(km5rack .or. kv5rack)) then
        write(lu_outfile,'(a,/,a,/,a,/,a)')
     >  '"Please change the following mk5b_mode command to reflect',
     >  '"the desired channel assingments and effective sample rate:',
     >  'mk5b_mode=ext,0xffffffff,1',
     >  'mk5b_mode'
         return
      endif

      idiv = 32/nint(samprate(icode))

! Remainder of code assumes that we have VSI4 formatter.
      ipass=1            !only 1 pass for Mark5B (or any disk)

! Make list containing tracks we use, and keep track of the number.
      num_tracks=0
      do isb=1,2
        do ibit=1,2
          do ihd=1,max_headstack
            do ic=1,max_chan
              it = itras(isb,ibit,ihd,ic,ipass,istn,icode)
              if (it.ne.-99) then         !number of tracks set.
                ib=ibbcx(ic,istn,icode)   !this is the BBC#
                num_tracks=num_tracks+1
                if(num_tracks .gt. max_csb) then
                  write(*,"(a)")
     >              "Proc_mk5b_tracks Error!  Too many channels"
                  write(*,*) "Max is ", max_csb
                  stop
                endif
                write(lsked_csb(num_tracks),'(i2.2,a1,a1)')
     >            ib, lul(isb), lsm(ibit)
              endif
            enddo
          enddo
        enddo
      enddo

! Check to see if a valid geo mode.
! Default is assume geo mode is true.
      kgeo_mode =.true.
      imask=0
      do ic=1,num_tracks
        ibit=iwhere_in_string_list(lgeo_csb,max_csb,lsked_csb(ic))
        if(ibit .eq. 0) then
           write(*,*) " "
           write(*,*) "Invalid m5b_geo  track: ", lsked_csb(ic)
           goto 200
        endif
        itemp=1
        itemp=ishft(itemp,ibit-1)
        imask=ior(imask,itemp)    !set the appropriate bit.
      end do
      goto 300                !only get here if all were found in valid geo list

200   continue
      kgeo_mode=.false.
! Check to see if a valid geodetic mode.
      imask=0
      do ic=1,num_tracks
        ibit=iwhere_in_string_list(lvlba_csb,max_csb,lsked_csb(ic))
        if(ibit .eq. 0) then
          write(*,*) " "
          write(*,*) "Invalid m5b_vlba track: ", lsked_csb(ic)
          return
        endif

        itemp=1
        itemp=ishft(itemp,ibit-1)
        imask=ior(imask,itemp)    !set the appropriate bit.
      end do
! only get here if all were found in valid geo list.


! A little bit of cleanup.
300   continue
      nchan_rec=8                 !can only record in units of 8,16, 32
      do j=1,3
        if(nchan_rec .lt. num_tracks) nchan_rec=nchan_rec*2
      end do

! If we need to, turn on extra bits until we get to 8, 16, or 32 channels.
      itemp=1
      do while(num_tracks .lt. nchan_rec)
        if(iand(itemp,imask) .eq. 0) then
           imask=ior(itemp,imask)             !bit not set. Set it.
           num_tracks=num_tracks+1
        endif
        itemp=ishft(itemp,1)            !shift the bit.
      end do

      write(cbuf,'("mk5b_mode=ext,0x",Z8.8,",",i2)') imask,idiv
      call squeezewrite(lu_outfile,cbuf)

      write(lu_outfile,'("mk5b_mode")')

      if(kgeo_mode) then
        write(lu_outfile,'("vsi4=geo")')
      else
        write(lu_outfile,'("vsi4=vlba")')
      endif
      write(lu_outfile,'("vsi4")')
      return

500   continue
      end
