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
      subroutine proc_track_mask_lines(lu_file, imask_hi,imask_lo,
     >   kfila10g_rack, samprate) 

! write out commands that look something like this:
!>>    fila10g_mode=,0x55555555,,16.00
!>>     fila10g_mode
!>>     mk5c_mode=vdif,0x55555555,,16.00
!>>     mk5c_mode 
! NOTE: fila10g mask is split in two:  32-bit High order and 32-bit low order. High order goes first.      
!       for the other modes, just one 64bit word (if  applicable). 
!       mk5c_mode mask is 

! History.

! 2020-12-31   JMGipson.  Added support for DBBC3_DDD.  In this case bit-mask is NULL. 
! 2018-09-11.  JMGipson.  First version.  sort-of taken from proc_dbbc_pfb_tracks. 
!

       implicit none
       include 'drcom.ftni'
! passed
       integer lu_file                !handle of file
       integer*4 imask_hi,imask_lo    !low and high order bits of mask
       logical kfila10g_rack          !fila10g_rack???
       real*4 samprate
! local   
       character*12 lsamprate
       integer nch, ierr

      call real_2_string(samprate,'(f11.4)', lsamprate,nch,ierr)   


!For fila10g, then have 64 bit masks. Else it is 32 bit. 
      if(kfila10g_rack) then
!Both masks are NULL.  Don't write them out.  
        if(imask_lo .eq. 0 .and. imask_hi .eq. 0) then 
          write(cbuf,'(a,"=,,,,",a)')
     >      'fila10g_mode', lsamprate   
! Don't write high order mask.  
        else if(imask_hi .eq. 0) then
          write(cbuf,'(a,"=,0x",z8.8,",,",a)')
     >      'fila10g_mode', imask_lo,lsamprate                 
        else
! write both. 
          write(cbuf,'(a,"=",2("0x",Z8.8,","),",",a)')
     >      'fila10g_mode', imask_hi,imask_lo,lsamprate                  
        endif
        call drudg_write(lu_file,cbuf)
        write(lu_file,'("fila10g_mode")') 
      endif

    
      if(lmode_cmd .eq. "bit_streams") then
        if(imask_lo .eq. 0 .and. imask_hi .eq. 0) then 
         write(cbuf,'(a,"=,,,,")')
     >      lmode_cmd
        else if(imask_hi .eq. 0) then 
          write(cbuf,'(a,"=",",0x",Z8.8,",,,")')
     >      lmode_cmd, imask_lo
        else
          write(cbuf,'(a,"=",2("0x",Z8.8,","),",,")') 
     >      lmode_cmd, imask_hi,imask_lo
        endif
      else 
        if(imask_lo .eq. 0 .and. imask_hi .eq. 0) then 
          write(cbuf,'(a,"=",a,",,,",a)')
     >      lmode_cmd,lext_vdif, lsamprate
        else if(imask_hi .eq. 0) then 
          write(cbuf,'(a,"=",a,",0x",Z8.8,",,",a)')
     >      lmode_cmd,lext_vdif, imask_lo,lsamprate
        else 
          write(cbuf,'(a,"=",a,",0x",2Z8.8,",,",a)')
     >      lmode_cmd,lext_vdif, imask_hi,imask_lo,lsamprate
        endif 
      endif 

      call drudg_write(lu_file,cbuf)
      call drudg_write(lu_file,lmode_cmd)     
      return
      end 
