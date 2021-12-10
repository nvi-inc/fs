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
      subroutine proc_thread(cproc_thread)
      implicit none 
      include 'drcom.ftni'
      include 'hardware.ftni' 
! generate new thread procedure
      character*(*) cproc_thread
     
      call proc_write_define(lu_outfile, luscn,cproc_thread)
      if(kflexbuff) then 
        write(lu_outfile,'(a)') "fb=datastream=clear"
        if(lvdif_thread .eq. "YES") then
          write(lu_outfile,'(a)') "fb=datastream=add:{thread}:*"
        endif
        write(lu_outfile,'(a)') "fb=datastream=reset"
      else
        write(lu_outfile,'(a)') "mk5=datastream=clear"
        if(lvdif_thread .eq. "YES") then
          write(lu_outfile,'(a)') "mk5=datastream=add:{thread}:*"
        endif
        write(lu_outfile,'(a)') "mk5=datastream=reset"
      endif
      write(lu_outfile,'(a)') "endef"
      end 
   


