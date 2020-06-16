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
      subroutine proc_s2_comments(icode,kroll)
      implicit none  !2020Jun15 JMGipson automatically inserted.
      include 'hardware.ftni'
      include 'drcom.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'

! passed
      integer icode
      logical kroll
! functions
      integer trimlen

      integer nch

      cbuf="rec_mode"
      nch=9
      if (krec_append) then
        cbuf(9:9)=crec(irec)
        nch=10
      endif
      cbuf(nch:nch+8)="="//cs2mode(istn,icode)
      nch=trimlen(cbuf)+1
      cbuf(nch:nch+1)=",$"
      nch=nch+2
C     If roll is NOT blank and NOT NONE then use it.
      if (kroll) then
        cbuf(nch:nch+4)=","//cbarrel(istn,icode)
      endif
      call lowercase_and_write(lu_outfile,cbuf)

      cbuf="user_info"
      nch=9
      if (krec_append) then
        cbuf(10:10)=crec(irec)
        nch=10
      endif

      write(lu_outfile,'(a,a)') cbuf(1:nch),'=1,label,station'
      write(lu_outfile,'(a,a)') cbuf(1:nch),'=2,label,source'
      write(lu_outfile,'(a,a)') cbuf(1:nch),'=3,label,experiment'
      write(lu_outfile,'(a,a,a)') cbuf(1:nch),'=3,field,',cexper
      write(lu_outfile,'(a,a,a)') cbuf(1:nch),'=1,field,,auto '
      write(lu_outfile,'(a,a,a)') cbuf(1:nch),'=2,field,,auto '
      call snap_data_valid('=off')

      return
      end

