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
      subroutine read_snap1(cbuf,cexper,iyear,cstn,cid1,cid2,ierr)

C Read the first comment line of a SNAP file in free-field format.
C Format:
C" VT2       1996 SHANG     S  
C           read(cbuf,9001) cexper,iyear,cstn,cid !header line
C9001        format(2x,a8,2x,i4,1x,a8,2x,a2)

C 970312 nrv Created to remove formatted reads.
! 2006Sep26. Rewritten to be simpler

C Called by: LSTSUM, CLIST, LABEL

C Input
      character*(*) cbuf
C Output
      character*8 cexper,cstn
      integer iyear
      character*2 cid2
      character*1 cid1
      integer ierr
! local

      ierr=0 
      cbuf(1:1)=" "   !get rid of first character.
      read(cbuf,*) cexper,iyear,cstn,cid1,cid2
      write(*,*) cexper,iyear,cstn,cid1,cid2
      return
      end
