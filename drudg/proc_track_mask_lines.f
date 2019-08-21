      subroutine proc_track_mask_lines(lu_file, imask_hi,imask_lo,
     >   kfila10g_rack, samprate, lmode_cmd,lext_vdif)

! write out commands that look something like this:
!>>    fila10g_mode=,0x55555555,,16.00
!>>     fila10g_mode
!>>     mk5c_mode=vdif,0x55555555,,16.00
!>>     mk5c_mode 
! NOTE: fila10g mask is split in two:  32-bit High order and 32-bit low order. High order goes first.      
!       for the other modes, just one 64bit word (if  applicable). 
!       mk5c_mode mask is 

! History.

! 2018Sep11.  JMGipson.  First version.  sort-of taken from proc_dbbc_pfb_tracks. 
!

       implicit none
! passed
       integer lu_file                !handle of file
       integer*4 imask_hi,imask_lo    !low and high order bits of mask
       logical kfila10g_rack          !fila10g_rack???
       real*4 samprate
       character*20 lmode_cmd         !what kind of mode (=mk5c_mode, mk5b_mode, bit_stream...)
       character*6 lext_vdif          !what kind of extension 
! local
       character*100 cbuf             !string to output.          
     

!For fila10g, then have 64 bit masks. Else it is 32 bit. 
      if(kfila10g_rack) then
! Don't write high order mask.  
        if(imask_hi .eq. 0) then
          write(cbuf,'(a,"=,0x",z8.8,",,",f9.3)')
     >      'fila10g_mode', imask_lo,samprate                 
        else
! write both. 
          write(cbuf,'(a,"=",2("0x",Z8.8,","),",",f9.3)')
     >      'fila10g_mode', imask_hi,imask_lo,samprate                  
        endif
        call drudg_write(lu_file,cbuf)
        write(lu_file,'("fila10g_mode")') 
      endif

    
      if(lmode_cmd .eq. "bit_streams") then
        if(imask_hi .eq. 0) then 
          write(cbuf,'(a,"=",",0x",Z8.8,",,,")')
     >      lmode_cmd, imask_lo
        else
          write(cbuf,'(a,"=",2("0x",Z8.8,","),",,")') 
     >      lmode_cmd, imask_hi,imask_lo
        endif
      else 
        if(imask_hi .eq. 0) then 
          write(cbuf,'(a,"=",a,",0x",Z8.8,",,",f9.3)')
     >      lmode_cmd,lext_vdif, imask_lo,samprate
        else 
          write(cbuf,'(a,"=",a,",0x",2Z8.8,",,",f9.3)')
     >      lmode_cmd,lext_vdif, imask_hi,imask_lo,samprate
        endif 
      endif 

      call drudg_write(lu_file,cbuf)
      call drudg_write(lu_file,lmode_cmd)     
      return
      end 
