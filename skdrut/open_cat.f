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
      subroutine open_cat(cat_name,ierr)
      include '../skdrincl/skparm.ftni'
      include 'skcom.ftni'
! Check to see if a catalog is there.
! If it is open it.
! If not, return with error message
! History
! 2005Nov21  JMGipson


      open(lucat,file=cat_name,status='old',iostat=ierr)
      nch = trimlen(cat_name)
      if (ierr.ne.0) then
        write(luscn,9011) ierr,cat_name(1:nch)
9011    format('Error ',i5,' opening catalog ',a)
        call flush(6)
        close(lucat)
        close(lutmp)
        return
      endif
      write(luscn,'(A,": ",$)') cat_name(1:nch)
      call flush(6)
      return
      end





