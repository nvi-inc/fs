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
      subroutine ckiau(ciau,ccom,rarad,decrad,lu)

C    CKIAU generates the IAU name and checks it against
C    the name of the source. Only the first 8 char are
C    checked.
!    2003Dec09 JMGipson changed hollerith to ascii

      include '../skdrincl/skparm.ftni'

C Input
      character*8 ciau, ccom
      integer lu
      real*8 rarad,decrad

C Called by: SOINP, WRSOS

C Local:
      character*8 ltest

      call getiauname(ltest,rarad,decrad)

      if(ltest .ne. ciau .and. lu .gt. 0) then
         write(lu,
     >    '("NOTE: IAU name for ",a, " should be ",a " not ",a)')
     >    ccom,ltest,ciau
      endif

      return
      end
