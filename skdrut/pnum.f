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
      character*1 function pnum(i)
C  Return the character corresponding to the pass index.
C 960527 nrv New.
C 970530 nrv "d" and "e" reversed!
      implicit none  !2020Jun15 JMGipson automatically inserted.

      integer i
      character*61 cp ! pass numbers
      character*1 cc

      data cp/'123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuv
     .wxyz'/

      cc = cp(i:i)
      pnum=cc
      return
      end
