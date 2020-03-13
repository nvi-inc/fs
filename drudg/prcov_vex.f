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
      subroutine prcov_vex

C Print PI cover letter from VEX files
C 000516 nrv New.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
      include 'drcom.ftni'

C Local
      integer jchar,i,ierr,ilen

      if (ireccv.eq.0) then ! none found
        write(luscn,9100)
9100    format('PRCOV00 -- No cover letter info was found.')
        return
      endif ! none found

      close(unit=LU_INFILE)
      open(unit=LU_INFILE,file=LSKDFI,status='old',iostat=IERR)
      if (ierr.ne.0) then
        write(luscn,9101) ierr,lskdfi
9101    format('PRCOV01 - Error ',i5,' opening ',a)
        return
      endif

      call setprint(ierr,0)
      do i=1,ireccv
        CALL READF_ASC(lu_infile,iERR,IBUF,ISKLEN,ILen)
      enddo
      CALL READF_ASC(LU_INFILE,IERR,IBUF,ISKLEN,ILEN)
      DO WHILE (IERR.GE.0.AND.ILEN.NE.-1.AND.JCHAR(IBUF,1).NE.odollar)
        write(luprt,'(80a2)') (ibuf(i),i=1,ilen)
        CALL READF_ASC(LU_INFILE,IERR,IBUF,ISKLEN,ILEN)
      enddo

      close(luprt)
      call prtmp(0)
      return
      end
