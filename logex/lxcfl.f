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
      subroutine lxcfl
C
C  COMMON BLOCKS USED:
C 
      include '../include/fscom.i'
      include 'lxcom.i'
C 
C      CALLING SUBROUTINES: 
C 
C      File manager package routines
C      Character manipulation routines
C 
C  LOCAL VARIABLES: 
C 
      character*79 outbuf
      integer answer, nchar, trimlen, ichmv
C 
C 
C Scan for an equals sign.
C
      if (iscn_ch(ibuf,1,nchar,'=').ne.0) goto 1510
      if (icmd.eq.0) call po_put_c(' none specified')
      if (icmd.eq.1) then
        outbuf='cfile=' // namcmc
        call po_put_c(outbuf)
      endif
      goto 1700
C
C Close command file if we are requesting a new file to be opened.
C Then obtain the command file name and open it.
C
1510  call fmpclose(idcbcm,ierr)
      istrc=ieq+1
      namcmc=' '
      id = ichmv(namcm,1,ibuf,istrc,nchar-istrc+1)
      call char2low(namcmc)
      call fmpopen(idcbcm,namcmc(1:nchar-istrc+1),ierr,'r',idum)
      if (ierr.ge.0) goto 1530
        outbuf='LXCFL90 - error '
        call ib2as(ierr,answer,1,4)
        call hol2char(answer,1,4,outbuf(17:))
        nchar = trimlen(outbuf) + 1
        outbuf(nchar:)=' opening command file ' // namcmc
        call po_put_c(outbuf)
        icode=-1
        goto 1700
1530  icmd=1
C
1700  continue
      return
      end
