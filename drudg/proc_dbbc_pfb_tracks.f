      subroutine proc_dbbc_pfb_tracks(lu_outfile,istn,icode)
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
             
! Write out DBBC_PFB commands...
! functions
  
! passed
      integer lu_outfile,istn,icode    

! History
!  2016Jan18 JMGipson.  First working version.

! local
      integer ic   
      integer num_out     !number written out
      integer nch         !character  location 
      integer i           !counter 
      integer ichan       !channel number
    
      integer*4 itemp
      integer*4 imask(2)  !Mask can be 64 bits long. 
     
      character*80 cbuf
      character*20 lmode_cmd
      character*6 lext_vdif             

! This holds strings of the form a02, b13, etc
      character*3  ltmp_array(32)
      integer      ikey(32)

      if(km5brec(1)) then
         lmode_cmd="mk5b_mode"
      else if(km5Crec(1)) then 
         lmode_cmd="mk5c_mode"
      else
         lmode_cmd="bit_streams"
      endif 
      lext_vdif="ext"
      if(kfila10g_rack.and.km5crec(1)) then
        lext_vdif="vdif" 
      endif             
    
! 
! Make the bit-mask.
! Initialize mask. 
       imask(1)=0
       imask(2)=0 
       write(*,*) "nchan= ", nchan(istn,icode)
       do i=1,nchan(istn,icode) 
         itemp=3             !always set 2 bits.
         if(i .le. 16) then 
           itemp=ishft(itemp,(i-1)*2)     !shift the bits into the appropriate place
           imask(2)=ior(imask(2),itemp)
         else
           itemp=ishft(itemp,(i-17)*2)
           imask(1)=ior(imask(1),itemp)
         endif
       end do
! Note imask(1) is the high-order which gets written out first. 
! write out commands that look something like this:
!>>    fila10g_mode=0x0000000055555555,,16.00
!>>     fila10g_mode
!>>     mk5c_mode=vdif,0x0000000055555555,,16.00
!>>     mk5c_mode 

!For fila10g, then have 64 bit masks. Else it is 32 bit. 
      if(kfila10g_rack) then
        if(imask(1) .eq. 0) then
          write(cbuf,'(a,"=,0x",z8.8,",,",f9.3)')
     >      'fila10g_mode', imask(2),samprate(istn,icode)                   
        else
          write(cbuf,'(a,"=0x",Z8.8,",0x",z8.8,",,",f9.3)')
     >      'fila10g_mode', imask(1:2),samprate(istn,icode)                   
        endif
        call drudg_write(lu_outfile,cbuf)
        write(lu_outfile,'("fila10g_mode")') 
      endif

      if(imask(1) .eq. 0) then 
        write(cbuf,'(a,"=",a,",0x",Z8.8,",,",f9.3)')
     >    lmode_cmd,lext_vdif, imask(2),samprate(istn,icode)
      else 
        write(cbuf,'(a,"=",a,",0x",2Z8.8,",,",f9.3)')
     >    lmode_cmd,lext_vdif, imask(1:2),samprate(istn,icode)
      endif 
    
      call drudg_write(lu_outfile,cbuf)
      call drudg_write(lu_outfile,lmode_cmd)     
! Now we have to write out the vsi1 and vsi2 commands. These look like...
!>>   form=flex 
!>>   vsi1=a02,a03,a04,a05,a06, c04,c05,c06    ....upto 16 channels.
!>>   vsi2=... for the next 16

! make an array of the stuff we will write out
      do ic=1,nchan(istn,icode)
         write(ltmp_array(ic),'(a,i2.2)') 
     &     cifinp(ic,istn,icode)(1:1), ibbcx(ic,istn,icode)
         call lowercase(ltmp_array(ic))
      end do 
      itemp=nchan(istn,icode)  !Do this because itemp is int*4
      call indexx_string(itemp,ltmp_array,ikey)

      write(lu_outfile,'(a)') "form=flex"
      num_out=0
      cbuf="vsi1="
      nch=6

      DO ic=1,nchan(istn,icode)  !loop on channels
! put in a comma if not the first one. 
         if(num_out .ne. 0) then
           cbuf(nch:nch)=","
           nch=nch+1
         endif      
         write(cbuf(nch:nch+2),'(a)')  ltmp_array(ikey(ic)) 
         nch=nch+3
        
         num_out=num_out+1
         if(num_out .eq. 16) then
           call drudg_write(lu_outfile,cbuf)    !write out the line. 
           cbuf="vsi2="
           nch=6
           num_out=0
         endif 
       end do
       if(ichan .gt. 17) then  !need to write out last line.
         call drudg_write(lu_outfile,cbuf)    !write out the line. 
       endif
       return   

900   continue
      write(*,*) 
     > "*********************************************************"
      write(*,*)
     > "ERROR in generating vsi section'"
     >
           write(*,*) "You will need to edit the PRC file."
      write(lu_outfile,'(a,/,a)')
     >  '"Please change the following command to reflect',
     >  '"the desired channel assignments and effective sample rate:'
         cbuf=lmode_cmd//'=ext,0xffffffff,,1.000'
      call drudg_write(lu_outfile,cbuf)
      call drudg_write(lu_outfile,lmode_cmd) 
      write(lu_outfile,'(a)') "form=UNKNOWN"

      end   
  

