      subroutine proc_disk_tracks(lu_outfile,istn,icode,
     >         kignore_mark5b_bad_mask)
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
     
     
! Write out Mark5B mode command.
! functions
      integer itras
! passed
      integer lu_outfile,istn,icode
      logical kignore_mark5b_bad_mask
! function
      integer iwhere_in_string_list

! History
!  2007Jul27 JMGipson.  First working version.
!  2012Aug29 JMGipson.  Modified to reduce minimum number of tracks.
!  2012Sep04 JMGipson.  Fixed bug in checking whether GEO or VLBA mode. 
!  2012Sep13 JMGipson.  Modified to handle DBBC rack 
!  2014Dec06 JMG.       Added Mark5C
!  2014Dec10 JMG.       Fixed error with sample rate. 
!  2015Jan13 JFHQ.      Support for DBBC E/F 'astro3' track layout.
!  2015Jan17 JFHQ.      Changed odd BBC exceptions to 1, 5, 9, 1+5, 1+9 (and 5+9)
!                       but only for bandwidths <= 16 MHz.
! 2015Jan20  JMG        Print sample rate to 3 places. Also put in line 900 for abort situations to branch to.
! 2015Jan22  JFHQ       Only allow (DBBC) 32 MHz bandwidth with E/F 'astro3'.
! 2015Jan30  JMG.       Function ITRAS returns values assuming that LO is normal. If it isn't, you need to swap U<-->L 
!           Also added suport for 'ignore_mark5b_bad_mask'.  If this flag is set, it will write a warning message
! 2015Feb04  JMG.       Minor typographic change if not DBBC. 
! 

! local
      integer ipass
      integer isb,ibit,ihd,ic
      integer isb_out
      integer ib
      integer num_tracks
      integer nchan_rec
    
      integer*4 itemp
      integer*4 imask
      integer iobs_mode             !Valid observing mode: 1=geo, 2=astro, 3=astro2, 4=astro3
      integer igeo_mode, iastro_mode, iastro2_mode, iastro3_mode
      parameter (igeo_mode=1, iastro_mode=2,iastro2_mode=3,
     >           iastro3_mode=4)
 
      integer idiv
      character*80 cbuf
      character*30 lcommand
      logical kcomment_only         !only put out comments.
      character*2 cprfix            !prefix (Either blank or ")

      character*1 lul(2)            !ASCII "U","L"
      character*1 lsm(2)            !ASCII "S","M"
      integer max_csb
      parameter (max_csb=32)

      character*4 lsked_csb(max_csb)     !Channel,sideband,bit in sked file
! Only two valid cases:
! 1.) VLBA mode:  All tracks fit within first 8 channels.
!     Can be upper or lower, sign or sign&magnitude.
! 2.) GEO mode: Channels 1-14 USB and channels 1&8 LSB.

      character*4 lvlba_csb(max_csb),    lgeo_csb(max_csb)
! Below added 2012Sep07.  
      character*4  lwastro_csb(max_csb), llba_csb(max_csb)
! Below added 2013Jun17   
      character*4 lastro2_csb(max_csb)
! Below added 2015Jan13   
      character*4 lastro3_csb(max_csb)
      character*4 lbbc159_csb(12)

! The order determines what bit is set.
! NOTE: This is the same astro mode.
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

! Note: 1st half of WASTRO is the same as ASTRO. This is for second 
      data lwastro_csb/
     >   "09US","09UM","10US","10UM","11US","11UM","12US","12UM",
     >   "13US","13UM","14US","14UM","15US","15UM","16US","16UM",
     >   "09LS","09LM","10LS","10LM","11LS","11LM","12LS","12LM",
     >   "13LS","13LM","14LS","14LM","15LS","15LM","16LS","16LM"/

! Note: This is for LBA.  Second set of 32 is same as first set. 
        data llba_csb/
     >   "01US","01UM","02US","02UM","05US","05UM","06US","06UM",
     >   "03US","03UM","04US","04UM","07US","07UM","08US","08UM",
     >   "01LS","01LM","02LS","02LM","05LS","05LM","06LS","06LM",
     >   "03LS","03LM","04LS","04LM","07LS","07LM","06LS","06LM"/

! ASTRO2  Added 2013Jun17
      data lastro2_csb/
     >   "01US","01UM","02US","02UM","03US","03UM","04US","04UM",
     >   "09US","09UM","10US","10UM","11US","11UM","12US","12UM",
     >   "01LS","01LM","02LS","02LM","03LS","03LM","04LS","04LM",
     >   "09LS","09LM","10LS","10LM","11LS","11LM","12LS","12LM"/

! ASTRO3  Added 2015Jan13
      data lastro3_csb/
     >   "01US","01UM","03US","03UM","05US","05UM","07US","07UM",
     >   "09US","09UM","11US","11UM","13US","13UM","15US","15UM",
     >   "01LS","01LM","03LS","03LM","05LS","05LM","07LS","07LM",
     >   "09LS","09LM","11LS","11LM","13LS","13LM","15LS","15LM"/

! BBC01/05/09   Added 2015Jan17
! - order not relevant here
      data lbbc159_csb/
     >   "01US","01UM","01LS","01LM","05US","05UM","05LS","05LM",
     >   "09US","09UM","09LS","09LM"/

      data lul/"U","L"/
      data lsm/"S","M"/

! If we don't have a VSI4 formatter or a DBBC write out comments.
      if(km5brec(1)) then
         lcommand="mk5b_mode"
      else if(km5Crec(1)) then 
         lcommand="mk5c_mode"
      else
         lcommand="bit_streams"
      endif 
      kcomment_only=.false.   
      if(.not.(km5rack .or. kv5rack .or. kdbbc_rack)) then
        kcomment_only=.true.  
        write(lu_outfile,'(a,/,a)')
     >  '"Please change the following command to reflect',
     >  '"the desired channel assignments and effective sample rate:'
         cbuf=lcommand//'=ext,0xffffffff,,1.000'
         call squeezewrite(lu_outfile,cbuf)
         call squeezewrite(lu_outfile,lcommand)     
      endif

      idiv = 32/nint(samprate(istn,icode))

! Remainder of code assumes that we have VSI4 formatter.
      ipass=1            !only 1 pass for Mark5B (or any disk)

! Make list containing tracks we use, and keep track of the number.
      num_tracks=0
      do isb=1,2 
        do ibit=1,2        
          do ic=1,max_chan
            isb_out=isb 
            if(abs(freqrf(ic,istn,icode)).lt.freqlo(ic,istn,icode)) then 
              isb_out=3-isb    !swap the sidebands
            endif ! reverse sidebands
            do ihd=1,max_headstack
              if (itras(isb,ibit,ihd,ic,ipass,istn,icode).ne.-99) then         !number of tracks set.
                ib=ibbcx(ic,istn,icode)   !this is the BBC#
                num_tracks=num_tracks+1    
                write(lsked_csb(num_tracks),'(i2.2,a1,a1)')
     >            ib, lul(isb_out), lsm(ibit)
              endif
            enddo
          enddo
        enddo
      enddo

      if(num_tracks .gt. max_csb) then
         write(*,"('Proc_disk_tracks Error! max_tracks is: ',i3)")
     >        max_csb
         write(*,"('But specfied ', i3)") num_tracks
         goto 900
!         if(kcomment_only) then
!           return
!         else
!          stop
!         endif 
       endif

     
100   continue
! Pre-check to see if a valid astro3 mode, but only for DBBC/Unknown racks
      if(.not.(kdbbc_rack .or. kcomment_only)) goto 110
      imask=0
      do ic=1,num_tracks
        ibit=iwhere_in_string_list(lastro3_csb,max_csb,lsked_csb(ic))
        if(ibit .eq. 0) then
          write(*,'(a)') "Channels are inconsistent with astro3... "
          goto 110 
        endif
        itemp=1
        itemp=ishft(itemp,ibit-1)
        imask=ior(imask,itemp)    !set the appropriate bit.
      end do 
!     But don't use astro3 mode for BBC01/05/09 only or in combination
      do ic=1,num_tracks
        ibit=iwhere_in_string_list(lbbc159_csb,12,lsked_csb(ic))
        if(ibit .eq. 0) goto 105
      end do 
      write(*,'(a)') "Channels are only from BBCs 1, 5 or 9... "
      if (idiv.ge.1) goto 200     ! prefer astro/astro2 in this case except for 32 MHz b/w
      write(*,'(a)') "  but channel bandwidth is wider than 16 MHz. "
      
105   continue
      iobs_mode=iastro3_mode 
      write(*,'("         Success!   Consistent with astro3 mode")') 
      goto 300		 ! only get here if all were found in valid astro3 list.

110   continue
! Check to see if a valid geo mode.
! Default is assume geo mode is true.
      if(kdbbc_rack .and. (idiv.lt.1)) then
          write(*,*) "Only astro3 mode supports 32 MHz channels."
          goto 900
      endif
      iobs_mode=0
      imask=0
      do ic=1,num_tracks
        ibit=iwhere_in_string_list(lgeo_csb,max_csb,lsked_csb(ic))
        if(ibit .eq. 0) then
          write(*,*) " "
          write(*,'("Warning: Channels inconsistent with mk5b_geo...")') 
          goto 200
        endif
        itemp=1
        itemp=ishft(itemp,ibit-1)
        imask=ior(imask,itemp)    !set the appropriate bit.
      end do
      iobs_mode=igeo_mode
      write(*,'("(Success! Passed m5b_geo consistency check)",$)') 
      goto 300                !only get here if all were found in valid geo list

200   continue     
! Check to see if a valid astro mode.
      imask=0
      do ic=1,num_tracks
        ibit=iwhere_in_string_list(lvlba_csb,max_csb,lsked_csb(ic))
        if(ibit .eq. 0) then      
          write(*,'("              and inconsistent with astro... ")')        
          if(.not.(kdbbc_rack .or. kcomment_only)) goto 900
          
          goto 220           
        endif
        itemp=1
        itemp=ishft(itemp,ibit-1)
        imask=ior(imask,itemp)    !set the appropriate bit.
      end do
      iobs_mode=iastro_mode
      write(*,'("         Success!   Consistent with astro mode")')   
      goto 300		 ! only get here if all were found in valid astro list.

220   continue
! Check to see if a valid astro2 mode.
      imask=0
      do ic=1,num_tracks
        ibit=iwhere_in_string_list(lastro2_csb,max_csb,lsked_csb(ic))
        if(ibit .eq. 0) then
          write(*,'(a)') "  .... and inconsistent with astro2... "              
          if(.not.kcomment_only) goto 900         
          goto 300 
        endif
        itemp=1
        itemp=ishft(itemp,ibit-1)
        imask=ior(imask,itemp)    !set the appropriate bit.
      end do 
      iobs_mode=iastro2_mode 
      write(*,'("         Success!   Consistent with astro2 mode")') 
      goto 300		 ! only get here if all were found in valid astro2 list.

! A little bit of cleanup.
300   continue

! Previously checked that num_tracks <= max_csb so we don't need to check that here.
! Mark5A record a minimum of 8 channels.
! Mark5B record a minimum of 1 channel.    
      if(km5b .or. km5c)  then
         nchan_rec=1
      else
         nchan_rec=8
      endif 

      do while(nchan_rec .lt. num_tracks)
        nchan_rec=nchan_rec*2
      end do      
	
! If we need to, turn on extra bits until we get to 1,2, 4, 8, 16, or 32 channels.
      itemp=1
      do while(num_tracks .lt. nchan_rec)
        if(iand(itemp,imask) .eq. 0) then
          imask=ior(itemp,imask)             !bit not set. Set it.
          num_tracks=num_tracks+1
        endif
        itemp=ishft(itemp,1)            !shift the bit.
      end do

      if(kcomment_only) then
        if(iobs_mode .eq. igeo_mode) then
          write(lu_outfile,'(a)')
     >      '" Channel assignments consistent with vsi4=geo'
        else if(iobs_mode .eq. iastro_mode) then
          write(lu_outfile,'(a)')
     >      '" Channel assignments consistent with vsi4=vlba'
        else if(iobs_mode .eq. iastro2_mode) then
          write(lu_outfile,'(a)')
     >      '" Channel assignments only consistent with form=astro2'
        else if(iobs_mode .eq. iastro3_mode) then
          write(lu_outfile,'(a)')
     >      '" Channel assignments only consistent with form=astro3'
        endif
        write(lu_outfile,'(a)') '" Appropriate mask follows'
      endif

      if(kcomment_only) then
        cprfix='"'
      else
        cprfix=' '
      endif 

      if(km5brec(1)) then
         lcommand="mk5b_mode"
      else if(km5crec(1)) then
         lcommand="mk5c_mode"
      else
         lcommand="bit_streams"
      endif 

! Modified 2014Dec03   
!      write(cbuf,'(a,a,"=ext,0x",Z8.8,",",i2)')
!     >  cprfix,lcommand, imask,idiv
! to ---> below
        write(cbuf,'(a,a,"=ext,0x",Z8.8,",,",f9.3)')
     >    cprfix,lcommand, imask,samprate(istn,icode) 
   

      call squeezewrite(lu_outfile,cbuf)
      if(kcomment_only) return

      call squeezewrite(lu_outfile,lcommand)     

      if(kdbbc_rack) then
        if(iobs_mode .eq. igeo_mode) then
          write(lu_outfile,'("form=geo")')
        else if(iobs_mode .eq. iastro_mode) then     
          write(lu_outfile,'("form=astro")')
        else if(iobs_mode .eq. iastro2_mode) then     
          write(lu_outfile,'("form=astro2")')
        else if(iobs_mode .eq. iastro3_mode) then     
          write(lu_outfile,'("form=astro3")')
        endif
        write(lu_outfile,'("form")') 
      else      
        if(iobs_mode .eq. igeo_mode) then
          write(lu_outfile,'("vsi4=geo")')
        else if(iobs_mode .eq. iastro_mode) then 
          write(lu_outfile,'("vsi4=vlba")')
        else if(iobs_mode .eq. iastro2_mode) then 
          write(*,*) "astro2 mode is only valid with dbbc!" 
          goto 900
        else
          write(*,*) "astro3 mode is only valid with dbbc!" 
          goto 900
        endif
        write(lu_outfile,'("vsi4")')
      endif 
      return

900   continue
      write(*,*) 
     > "*********************************************************"
      write(*,*)
     > "ERROR(proc_disk_tracks)! No valid Mark5B mask/mode found."
     >
      if(.not.kignore_mark5b_bad_mask) then
          write(*,*) "Please fix file and start again."
        stop
      endif
      write(*,*) "You will need to edit the PRC file."
      write(lu_outfile,'(a,/,a)')
     >  '"Please change the following command to reflect',
     >  '"the desired channel assignments and effective sample rate:'
         cbuf=lcommand//'=ext,0xffffffff,,1.000'
      call squeezewrite(lu_outfile,cbuf)
      call squeezewrite(lu_outfile,lcommand) 
      write(lu_outfile,'(a)') "form=UNKNOWN"

      end   
  

