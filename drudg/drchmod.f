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
      subroutine drchmod(cname,ierr)
      implicit none 
! 2013Jan15 JMGipson. Rewritten and modified.
! 2015Mar30 JMG. Got rid of obsolete argument iperm. 
! 2019Aug21 JMG.  "666-->664" because of NASA IT requirements. Do not want world-writable
C Input
      character*128 cname   
C Output
      integer ierr    
! Function
      integer system 
C Local
      integer trimlen
      integer nch 

      nch=trimlen(cname)
      ierr= system("chmod 664 "//cname(1:nch)//char(0))
      return

      end
