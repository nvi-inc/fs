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
      Subroutine prtmp(iopt)
C  PRTMP prints the temp file
c  NRV 910703
C  nrv 950925 Change to simply call "printer". Landscape or
C             portrait is handled by each listing type.
C  nrv 951015 Revert to using cprtpor and cprtlan , and if blank
C             then "printer" will handle them.
C 960226 nrv Send "cprtlab" as script name for labels
C 970207 nrv Add iopt to call and use it instead of iwidth.
! 2015Mar30  JMG. modified to change mode of tmpname.

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      integer ierr,iopt
      integer printer ! function

      if (cprport.ne.'PRINT') return

      call null_term(tmpname)

      if (klab) then ! labels
        ierr = printer(labname,'l',cprtlab)
      else ! normal prinout
        call drchmod(tmpname,ierr) 
        if (iopt.eq.0) then
          ierr = printer(tmpname,'t',cprtpor)
        else if (iopt.eq.1) then
          ierr = printer(tmpname,'t',cprtlan)
        else
          ierr = -1
        end if
      endif

      if (ierr.ne.0) then
         write(luscn,9062) ierr
9062     format(' PRINTER01 - Error ',i5,' calling printer')
      else
         if (klab) then
           open(luprt,file=labname,status='old')
           close(luprt,status='delete')
         else
           open(luprt,file=tmpname,status='old')
           close(luprt,status='delete')
         endif
      end if
   
      RETURN
      END
