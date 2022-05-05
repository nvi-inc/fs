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
      SUBROUTINE VGLINP(ivexnum,LU,IERR,iret)

C  This routine gets the experiment information.
C  For now, the experiment name, description and PI name are put
C  in common.
C  Called by drudg/SREAD. 
C
C History
C 960603 nrv New.
C 970124 nrv Add iret to call.
! 2006Nov18 JMGipson. Converted lexper to ASCII.
! 2018Dec22.  Added implicit none.  Previuosly used undefined variable 'ccorname'
      implicit none

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
C
C  INPUT:
      integer ivexnum,lu
C
C  OUTPUT:
      integer ierr ! error from this routine

C  CALLED BY: 
C  CALLS:  fget_global_lowl         (get global info)
C
C  LOCAL:
      character*128 cout
      integer iret,nch
! functions
      integer fget_global_lowl,fvex_field,ptr_ch,fvex_len

C Initialize.

      cexper=" "
      cexperdes=' '
      cpiname=' '
      ccorname=' '

C 1. Get experiment name
!      write(*,*) "VGLINP 1" 

      ierr=1
      iret = fget_global_lowl(ptr_ch('exper_name'//char(0)),
     & ptr_ch('EXPER'//char(0)),ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout))
      nch=fvex_len(cout)
      if (nch.gt.8) then
        write(lu,'("VEXINP01 - Experiment name too long, using first ",
     .  "8 characters")') 
        nch=8
      endif
      cexper=cout(1:nch)

C 2. Get experiment description
!      write(*,*) "VGLINP 2" 

      ierr=2
      iret = fget_global_lowl(ptr_ch('exper_description'//char(0)),
     & ptr_ch('EXPER'//char(0)),ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout))
      nch=fvex_len(cout)
      if (nch.gt.128) then
        write(lu,'("VEXINP02 - Experiment description too long, ",
     .  "using first 128 characters")') 
        nch=128
      endif
      if (nch.gt.0) cexperdes=cout(1:nch)

C 3. Get PI name
!      write(*,*) "VGLINP 3" 
      ierr=3
      iret = fget_global_lowl(ptr_ch('PI_name'//char(0)),
     &  ptr_ch('EXPER'//char(0)),ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout))
      nch=fvex_len(cout)
      if (nch.gt.128) then
        write(lu,'("VEXINP03 - PI name too long, ",
     .  "using first 128 characters")') 
        nch=128
      endif
      if (nch.gt.0) cpiname=cout(1:nch)

C 4. Get correlator
!      write(*,*) "VGLINP 4" 
      ierr=4

      iret = fget_global_lowl(ptr_ch('target_correlator'//char(0)),
     & ptr_ch('EXPER'//char(0)),ivexnum)
      if (iret.ne.0) return

      iret = fvex_field(1,ptr_ch(cout),len(cout))
      nch=fvex_len(cout)
      if (nch.gt.128) then
        write(lu,'("VEXINP04 - Correlator name too long, ",
     .  "using first 128 characters")') 
        nch=128
      endif
      if (nch.gt.0) then 
         ccorname=cout(1:nch)
      endif
      call capitalize(ccorname)
  
      ierr=0
      return
      end
