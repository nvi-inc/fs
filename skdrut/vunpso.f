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
      SUBROUTINE vunpso(sodef,ivexnum,iret,ierr,lu,
     >   cname1,cname2,rarad,decrad,iep)
C
C     VUNPSO gets the source information for source sodef.
C     **NOTE** Satellites as sources not supported yet.
C     All statements are gotten and checked before returning.
C     Any invalid values are not loaded into the returned
C     parameters.
C     Only generic error messages are written. The calling
C     routine should list the station name for clarity.
C
      include '../skdrincl/skparm.ftni'
C
C  History:
C 960527 nrv New.
C 970114 nrv Change 4 to max_sorlen/2
C 970124 nrv Move initialization to start
! 2006Nov18 JMGipson. Converted lname1,lname2 to ASCII
! 2007Jul02 JMGipson. Changed so that maximum length nch=max_sorlen,
!                     previously was hardwired to 8.
C
C  INPUT:
      character*128 sodef ! source def to get
      integer ivexnum ! vex file ref
      integer lu ! unit for writing error messages
C
C  OUTPUT:
      integer iret ! error return from vex routines, !=0 is error
      integer ierr ! error from this routine, >0 indicates the
C                    statement to which the VEX error refers,
C                    <0 indicates invalid value for a field
      character*(max_sorlen) cname1,cname2
      integer iep ! epoch, 1950 or 2000
      double precision rarad,decrad
C
C  LOCAL:
      character*128 cout
      double precision R
      integer nch
      integer fvex_ra,fvex_dec,fvex_len,fget_source_lowl,fvex_field
      integer ptr_ch
C
C  Initialize
C
      cname1 =" "
      cname2 =" "
      rarad  = 0.d0
      decrad = 0.d0
      iep=0

C  1. The IAU name.
C
      ierr = 1
      iret = fget_source_lowl(ptr_ch(sodef),ptr_ch('IAU_name'//char(0)),
     .ivexnum)
      if (iret.eq.0) then
        iret = fvex_field(1,ptr_ch(cout),len(cout))
        NCH = fvex_len(cout)
        IF  (NCH.GT.max_sorlen.or.NCH.le.0) THEN 
          write(lu,'("VUNPSO01 - IAU name too long, using first ",i3,
     .    " characters")') max_sorlen
          ierr=-1
          nch=max_sorlen
        ENDIF
        cname1=cout(1:nch)
      endif
C
C  2. The common name.
C
      ierr = 2
      iret = fget_source_lowl(ptr_ch(sodef),
     .ptr_ch('source_name'//char(0)),
     .ivexnum)
      if (iret.eq.0) then
        iret = fvex_field(1,ptr_ch(cout),len(cout))
        NCH = fvex_len(cout)
        IF  (NCH.GT.max_sorlen.or.NCH.le.0) THEN
          write(lu,'("VUNPSO02 - Comon name too long, using first ",
     .    i3," characters")') max_sorlen
          ierr=-2
          nch=max_sorlen
        ENDIF
        cname2=cout(1:nch)
      else
        ierr=-21
        write(lu,'("VUNPSO21 - Source comon name missing")')
      endif
C
C  3.  RA
C
      ierr = 3
      iret = fget_source_lowl(ptr_ch(sodef),ptr_ch('ra'//char(0)),
     .ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout))
      if (iret.ne.0) return
      iret = fvex_ra(ptr_ch(cout),r) ! convert to radians
      IF  (Iret.ne.0) THEN
        Ierr = -3
        write(lu,'("VUNPSO03 - Invalid RA.")')
      else
        rarad = R
      endif

C  4.  Dec
C
      ierr = 4
      iret = fget_source_lowl(ptr_ch(sodef),ptr_ch('dec'//char(0)),
     .ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout))
      if (iret.ne.0) return
      iret = fvex_dec(ptr_ch(cout),r) ! convert to radians
      IF  (Iret.ne.0) THEN
        Ierr = -4
        write(lu,'("VUNPSO04 - Invalid Dec.")')
      else
        decrad = R
      endif

C  5.  Epoch
C
      ierr = 5
      iret = fget_source_lowl(ptr_ch(sodef),
     .ptr_ch('ref_coord_frame'//char(0)),
     .ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout))
      if (iret.ne.0) return
      nch=fvex_len(cout)
      if (cout(1:nch).eq.'J2000') then
        iep=2000
      else if (cout(1:nch).eq.'B1950') then
        iep=1950
      else 
        Ierr = -5
        write(lu,'("VUNPSO05 - Invalid epoch, only J2000 or B1950")')
      endif

      if (ierr.gt.0) ierr=0
      return
      end
