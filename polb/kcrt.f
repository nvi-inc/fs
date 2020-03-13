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
      logical function kcrt(lut,ierr,ipbuf,jerr)

      logical kfmp
      character*(*) ipbuf
C
      integer*2 lcret(6)
C
      data lcret  /   9,2Hcr,2Hea,2Hti,2Hng,2H_ /
C          creating_

      kcrt=.false.
      if (jerr.eq.ierr) return
      kcrt=kfmp(lut,ierr,lcret(2),lcret(1),ipbuf,1,0)

      return
      end
