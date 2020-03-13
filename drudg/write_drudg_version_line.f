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
      subroutine write_drudg_version_line(lu_out)
      implicit none 
      integer lu_out
      include 'drver_com.ftni'
       character*2 cprfx
       integer trimlen
! 2018Jul20 First version

      cprfx='" '
    
      write(lu_out,
     > "(a,'drudg version ',a9,' compiled under FS ',i2,2('.',i2.2),$)")
     >    cprfx,cversion,iVerMajor_FS,iverMinor_FS,iverPatch_FS

      if(crel_FS .eq. " ") then
        write(lu_out, '(a)') " "
      else 
        write(lu_out,'(a)') "-"//Crel_FS(1:trimlen(Crel_FS))
       endif
       return
       end
