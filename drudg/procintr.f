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
      SUBROUTINE PROCINTR
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
C This routine writes out the header information for proc files.
C into lu_outfile.
C
      include 'hardware.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
C
C History
C 970225 nrv New. Copied from snapintr.
C 990512 nrv Add rack and rec types to call so that they can be
C            printed in the proc library header.
C 990520 nrv Add FS and drudg versions to the comment headers.
C 990803 nrv Merge FS and drudg lines and reformat.
C 991101 nrv k*rec variables are dimensioned (2) and messages
C            show recorder A or B.
C 991210 nrv Write equipment name from common.
C 991214 nrv Remove calling parameters, not nneeded.
! 2005Aug08 JMGipson.  Simplified.
! 2006Nov30 Use cstrec(istn,irec) instead of 2 different arrays
! 2018Jul20 Moved writing of drudg version to subrotine.

C Input
!    None.

! functions
C  LOCAL:
      character*2 cprfx

      cprfx='" '
C
      write(lu_outfile,'(a)') "define  proc_library  00000000000x"

      if(cexper .eq.  " ") cexper="XXX"

      write(lu_outfile,'(a,a,3x,a,2x,a)')
     > cprfx,cexper,cstnna(istn),cpocod(istn)

      call write_drudg_version_line(lu_outfile)


      write(lu_outfile,'(5a,$)')
     >   '"< ',cstrack(istn),' rack >< ',cstrec(istn,1), ' recorder 1>'
      if(nrecst(istn) .eq. 2) then
        write(lu_outfile,'("< ",a," recorder 2>")') cstrec(istn,2)
      else
        write(lu_outfile, '(a)')
      endif

      if(km5A_piggy) then
        write(lu_outfile,90) "   Mark5A operating in piggyback mode."
      endif
      if(km5P_piggy) then
        write(lu_outfile,90) "   Mark5P operating in piggyback mode."
      endif

      write(lu_outfile,'(a)') 'enddef'

90    format('"',a,'"')
C
      RETURN
      END

