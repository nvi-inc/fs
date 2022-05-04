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
      subroutine proc_dbbc3_ddc_tracks(lu_file,istat,icode)
      implicit none  
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
      include 'drcom.ftni'

! Write out DBBC_PFB commands...
! functions

! passed
      integer lu_file,istat,icode

! History
! Now most recent at the top.
! 2021-01-12 JMG First version. Based loosely on proc_disk_tracks 
!
! local

      integer*4 imask(2)  !Mask can be 64 bits long.
      integer*4 imask_lo, imask_hi
      equivalence(imask(1),imask_hi)
      equivalence(imask(2),imask_lo)

            
! Initialize mask to NULL. 
       imask(1)=0
       imask(2)=0         

       call proc_track_mask_lines(lu_file, imask_hi,imask_lo,
     >   kfila10g_rack,samprate(istat,icode)) 

      end


