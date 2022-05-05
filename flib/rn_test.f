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
      logical function rn_test(name)
      implicit none
      character*(*) name
c
c  rn_test: resource name test (test lock semaphore for name)
c
c  input: name (first 5 character significant)
c
c  output: (return value) .true. if locked, .false. otherwise
c
      integer fc_nsem_test
c
      rn_test=fc_nsem_test(name).ne.0
      return
      end
