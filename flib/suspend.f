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
      subroutine suspend(name)
      implicit none
      character*(*) name
c
c  suspend: suspend on GO semaphore for name (take GO semaphore for name)
c           waiting for a go_suspend
c
c  input: name (first 5 character significant)
c
c  output: (return value) =0 successful lock
c                         =1 already locked
c           errors terminate
c
      call fc_go_take(name,0)
      return
      end






