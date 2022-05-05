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
C@skTIME
      subroutine sktime(cbuf,ctime)
C
C     sktime: returns the time field for an observation record
      include '../skdrincl/skparm.ftni'
! 2005Nov30 JMGipson. Rewritten to use ascii.

C  INPUT VARIABLES
      character*(*) cbuf  !buffer holding observation.
! Output
      character*12 ctime

! local
      integer MaxToken
      integer NumToken
      parameter(MaxToken=10)
      character*16 ltoken(MaxToken)

      call splitNtokens(cbuf,ltoken,Maxtoken,NumToken)

      ctime=ltoken(5)
      return
      end
