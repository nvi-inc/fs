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
      integer function rn_take(name,flags)
      implicit none
      character*(*) name
      integer flags
c
c  rn_take: resource name take (lock semaphore for name)
c
c  input: name (first 5 character significant)
c         flags =0 block, =1 non-blocking
c
c  output: (return value) =0 successful lock
c                         =1 already locked
c           errors terminate
c
      integer fc_nsem_take
c
      rn_take=fc_nsem_take(name,flags)
      return
      end
