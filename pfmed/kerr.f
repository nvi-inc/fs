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
      logical function kerr(ierr,who,what,fname,iner,jner)
      implicit none
C
C  This function writes an error message to the users terminal.
C
C  WHO  WHEN    DESCRIPTION
C  WEH  901101  CREATED
C
C  INPUT VARIABLES
      integer ierr,iner,jner
      character*(*) who,what,fname
C
C  LOCAL VARIABLES
C
C
      kerr=.false.
      if(ierr.eq.0) return
      if(iner.eq.ierr) return
      if(jner.gt.0.and.ierr.gt.0) return
      kerr=.true.
C
      write(6,1) who,ierr,what,fname
1     format('pfmed'/' ',a,': error ',i7,' ',a,' ',a)
      return
      end
