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
      subroutine snap_disk2file_abort(lufile)
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/data_xfer.ftni'

! passed
      integer lufile
      integer trimlen
      integer nch

      nch =max(trimlen(lautoftp_string),1)

      if(kautoftp) then
        write(lufile,'(a)')
     >      "disk2file=abort,autoftp,"//lautoftp_string(1:nch)
      else
        write(lufile,'(a)') "disk2file=abort,,"
      endif

      return
      end
