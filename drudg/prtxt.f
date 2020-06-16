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
      subroutine prtxt
      implicit none  !2020Jun15 JMGipson automatically inserted.

C Print .txt file (if any)
C 980916 nrv Copy from prcov
C 990117 nrv Simply call 'printer' to print the file instead of
C            reading then writing each line.
C 991211 nrv Print file name in error message.

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'

C Local
      integer i,ierr
      integer printer,trimlen ! function
      character*20 ccmd
      logical kex

      INQUIRE(FILE=ctextname,EXIST=KEX)
      if (.not.kex) then ! none found
        i=trimlen(ctextname)
        write(luscn,9100) ctextname(1:i)
9100    format('PRTXT00 -- The notes file ',a,' was not found.')
        return
      endif ! none found

C     open(unit=LU_INFILE,file=ctextname,status='old',iostat=IERR)
C     if (ierr.ne.0) then
C       write(luscn,9101) ierr,ctextname
C9101    format('PRCOV01 - Error ',i5,' opening ',a)
C       return
C     endif
C     close(lu_infile)

C     call setprint(ierr,0)
C     CALL READF_ASC(LU_INFILE,IERR,IBUF,ISKLEN,ILEN)
C     DO WHILE (IERR.GE.0.AND.ILEN.NE.-1)
C       write(luprt,'(80a2)') (ibuf(i),i=1,ilen)
C       CALL READF_ASC(LU_INFILE,IERR,IBUF,ISKLEN,ILEN)
C     enddo

C     close(luprt)
C     call prtmp(0)

      call null_term(ctextname)
      ccmd = 'lpr'
      call null_term(ccmd)
      ierr = printer(ctextname,'t',ccmd)
      return
      end
