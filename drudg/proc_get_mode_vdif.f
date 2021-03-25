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
      subroutine proc_get_mode_vdif(cstrec,kfila10g)
      implicit none 
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      character*(*) cstrec
      logical kfila10g
   
! History.
! 2021-02-08  JMG Now vdif for Flexbuff and Mark5C. Previously only if fil10g. 
! 2021-01-25  JMG now sets lext_vdif and lmode_mcd in drcom.ftni
! 2020-12-29. JMG First version. Used by proc_dbbc_pfb_tracks and proc_disk_tracks, proc_dbbc3_ddc...

      lext_vdif="ext"
      if(cstrec .eq."Mark5B") then
         lmode_cmd="mk5b_mode"
      else if(cstrec .eq. "FlexBuff") then
         lmode_cmd="fb_mode"
         lext_vdif="vdif"
      else if(cstrec .eq. "Mark5C") then
         lmode_cmd="mk5c_mode"
         lext_vdif="vdif"
      else
         lmode_cmd="bit_streams"
      endif
      return
      end 
