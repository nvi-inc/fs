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
      subroutine setup_name(lcode,cnamep) 
      implicit none 
C SETUP_NAME generates the setup procedure name.
! passed.
      character*(*) lcode
! returned
      character*12 cnamep 
! 2014Jan17 JMG. Since we no longer have passes, made much simpler.
! functions    
      integer trimlen    
! local
   
      cnamep='setup'//lcode(1:trimlen(lcode))
      call lowercase(cnamep)    
      return
      end
