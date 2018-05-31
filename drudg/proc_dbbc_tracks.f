      subroutine proc_dbbc_pfb_tracks(lu_file,istat,icode)
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
      include 'drcom.ftni'
             
! Write out DBBC_PFB commands...
! functions
  
! passed
      integer lu_file,istat,icode    

! History
! 2016Jan18 JMGipson.  First working version.
! 2016May07 WEH        reorder vsi1/vsi2, remove unitialized ichan bug
! 2016Sep08 JMG.  Added in vsi_align command.  To get 'lvsi_prompt' had to include drcom.ftni.
!                 Including drcom.ftni meant I had to rename some variables because of collisions. 
! 2016Sep11 JMG. Make vsi_align input appear on same line as prompt
! 2017Oct24 JMG. If 'bit_streams' then only care about mask. Everything else is null.

! local
      integer ic   
      integer num_out     !number written out
      integer nch         !character  location 
      integer i           !counter 
    
      integer*4 itemp
      integer*4 imask(2)  !Mask can be 64 bits long. 
     
!      character*80 cbuf
      character*20 lmode_cmd
      character*6 lext_vdif  
      character*4 lvsi_align   !holds vsi_align value=0,1,NONE,ASK           

! This holds strings of the form a02, b13, etc
      character*3  ltmp_array(32)
      integer      ikey(32)

      lext_vdif="ext"
      if(km5brec(1)) then
         lmode_cmd="mk5b_mode"
      else if(km5Crec(1)) then 
         lmode_cmd="mk5c_mode"
         if(kfila10g_rack) lext_vdif="vdif"       
      else
         lmode_cmd="bit_streams"
      endif
               
! 
! Make the bit-mask.
! Initialize mask. 
       imask(1)=0
       imask(2)=0 
!       write(*,*) "nchan= ", nchan(istat,icode)
       do i=1,nchan(istat,icode) 
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
     >      'fila10g_mode', imask(2),samprate(istat,icode)                   
        else
          write(cbuf,'(a,"=0x",Z8.8,",0x",z8.8,",,",f9.3)')
     >      'fila10g_mode', imask(1:2),samprate(istat,icode)                   
        endif
        call drudg_write(lu_file,cbuf)
        write(lu_file,'("fila10g_mode")') 
      endif

      if(imask(1) .eq. 0) then 
        write(cbuf,'(a,"=",a,",0x",Z8.8,",,",f9.3)')
     >    lmode_cmd,lext_vdif, imask(2),samprate(istat,icode)
      else 
        write(cbuf,'(a,"=",a,",0x",2Z8.8,",,",f9.3)')
     >    lmode_cmd,lext_vdif, imask(1:2),samprate(istat,icode)
      endif 

      if(lmode_cmd .eq. "bit_streams") then
        if(imask(1) .eq. 0) then 
          write(cbuf,'(a,"=",",0x",Z8.8,",,,")')lmode_cmd, imask(2)
        else
          write(cbuf,'(a,"=",",0x",Z8.8,",,,")') lmode_cmd, imask(1:2)
        endif
      endif 
    
      call drudg_write(lu_file,cbuf)
      call drudg_write(lu_file,lmode_cmd)     
! Now we have to write out the vsi1 and vsi2 commands. These look like...
!>>   form=flex 
!>>   vsi2=a02,a03,a04,a05,a06, c04,c05,c06    ....upto 16 channels.
!>>   vsi1=... for the first 16

! make an array of the stuff we will write out
      do ic=1,nchan(istat,icode)
         write(ltmp_array(ic),'(a,i2.2)') 
     &     cifinp(ic,istat,icode)(1:1), ibbcx(ic,istat,icode)
         call lowercase(ltmp_array(ic))
      end do 
      itemp=nchan(istat,icode)  !Do this because itemp is int*4
      call indexx_string(itemp,ltmp_array,ikey)

      write(lu_file,'(a)') "form=flex"
      
      lvsi_align=lvsi_align_prompt
      call capitalize(lvsi_align)
      if(lvsi_align .eq. " ") lvsi_align="NONE"

! insert vsi_align command if necessary     
       do while(lvsi_align .ne. "0" .and. 
     &          lvsi_align .ne. "1" .and.
     &          lvsi_align .ne. "NONE")   
        write(*,'(a,$)' ) "Enter in vsi_align (0,1,none): "
        read(*, '(a)') lvsi_align
        call capitalize(lvsi_align)
      end do 
 
      if(lvsi_align .eq. "0") then
        write(lu_file,'("dbbc=vsi_align=0")')
      else if(lvsi_align .eq. "1") then
        write(lu_file,'("dbbc=vsi_align=1")')
      endif      

      if(nchan(istat,icode). gt. 16) then
         cbuf="vsi2="
         nch=6
         num_out=0
         DO ic=17,nchan(istat,icode) !loop on channels
            if(num_out .ne. 0) then
               cbuf(nch:nch)=","
               nch=nch+1
            endif      
            write(cbuf(nch:nch+2),'(a)')  ltmp_array(ikey(ic)) 
            nch=nch+3
            num_out=num_out+1
         enddo
         call drudg_write(lu_file,cbuf) !write out the line. 
      endif

      cbuf="vsi1="
      nch=6
      num_out=0
      DO ic=1,min(16,nchan(istat,icode)) !loop on channels on vsi1
! put in a comma if not the first one. 
         if(num_out .ne. 0) then
            cbuf(nch:nch)=","
            nch=nch+1
         endif      
         write(cbuf(nch:nch+2),'(a)')  ltmp_array(ikey(ic)) 
         nch=nch+3
         num_out=num_out+1
      end do
      if(num_out.gt.0) then    !need to write out last line.
         call drudg_write(lu_file,cbuf) !write out the line. 
      endif
      return   

900   continue
      write(*,*) 
     > "*********************************************************"
      write(*,*)
     > "ERROR in generating vsi section'"
     >
           write(*,*) "You will need to edit the PRC file."
      write(lu_file,'(a,/,a)')
     >  '"Please change the following command to reflect',
     >  '"the desired channel assignments and effective sample rate:'
         cbuf=lmode_cmd//'=ext,0xffffffff,,1.000'
      call drudg_write(lu_file,cbuf)
      call drudg_write(lu_file,lmode_cmd) 
      write(lu_file,'(a)') "form=UNKNOWN"

      end   
  
