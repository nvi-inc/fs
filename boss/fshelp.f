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
      subroutine fshelp(ibuf,istart,nchar,ierr)
C
      include '../include/fscom.i'
C  INPUT VARIABLES:
      integer*2 ibuf(1)    ! command buffer
C     ISTART: INDEX OF START OF NAME OF COMMAND FOR WHICH HELP IS DESIRED
C     NCHAR:  END OF COMMAND STRING
C  OUTPUT VARIABLES: none
C  LOCAL VARIABLES:
C     RUNSTR:  runstring for calling programs
C  PROGRAMMER:  Lloyd Rawley     early February 1988
C
      character*100 runstr,cstring,rstring

      if (istart.ne.0) then
        length = nchar+1-istart
        if(length.gt.100) then
           nchar=istart+100-1
           length=100
        endif
        call hol2char(ibuf,istart,nchar,cstring)
      else
        cstring='help.___'
        length=7
      endif
c
      call fs_get_drive(drive)
      call fs_get_rack(rack)
      ierr = 0
      call helpstr(cstring,length,rstring,rack,drive(1),drive(2),ierr)
      if(ierr.eq.0) then
        runstr= 'helpsh '//rstring
        call ftn_runprog(runstr,idum)
c       else
c       call putcon_ch('No help for '//cstring(:length)//
c     &        ', maybe your equipment type is wrong')
      endif
c
9999  continue
      return
      end
