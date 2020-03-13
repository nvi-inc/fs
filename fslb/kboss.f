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
      logical function kboss()
C
      include '../include/fscom.i'
C
      logical rn_test
C
C     This routine returns the status of BOSS based on the resource
C     allocation variable IRNBOSS_FS.
C
C  WHO  WHEN    DESCRIPTION
C  GAG  901226  Created.
C
      kboss=rn_test('fs   ')
C
      return
      end
