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
       subroutine pname(ibuf)
       integer*2 ibuf(3)
       integer*2 ibuf_cm(3)
       common/pname_com/ibuf_cm
       inext=ichmv(ibuf,1,ibuf_cm,1,5)
       return
       end
       subroutine putpname(cbuf)
       character*(*) cbuf
       integer*2 ibuf_cm(3)
       common/pname_com/ibuf_cm
       call char2hol(cbuf,ibuf_cm,1,5)
       return
       end
