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
      subroutine snap_start_recording(kin2net) 
      include 'hardware.ftni'
      logical kin2net
! 2005Jul28  JMGipson.  Added "disk_record" after disk_record_on
! 2014Jan30  JMGipson. Removed disk crap. 
      
      if(km5disk) then
        if(kin2net) then
            write(lufile,'(a)') "in2net=on"
        else
           write(luFile,'("disk_record=on")')
           write(luFile,'("disk_record")')  
        endif
      endif 
      krunning=.true.           !turn on running flag.

      return
      end
