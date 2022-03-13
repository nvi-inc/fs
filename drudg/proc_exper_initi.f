*
* Copyright (c) 2020-2022 NVI, Inc.
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
      subroutine proc_exper_initi(lufil,luscn,kin2net_on)
      implicit none  !2020Jun15 JMGipson automatically inserted.
      include 'hardware.ftni'
! passed
      integer lufil,luscn
      logical kin2net_on

! functions

! local
      character*12 lname
! History
! 2022-02-08 JMG. For fila10g utput "fila10g=version"
! 2021-09-28 JMG. Treat mk5c or flexbuff differently
! 2021-01-31 JMG Modified for DBBC3_DDC 
! 2007May28 JMGipson.  Modified to add Mark5B support.
! 2014Dec06 JMG. Added Mark5C support
! 2015Jun05 JMG.  A.) Don't output 'mk5=ss_rev?';  B.) Lowercase all output text.
! 2016Sep06 JMG. Replace 'mk5=status?' with 'mk5_status'

      lname="exper_initi"

      call proc_write_define(luFil,luscn,lname)
      write(luFile,'(a)') "proc_library"
      write(luFile,'(a)') "sched_initi"

      if(kin2net_on .and. (km5A .or. km5B)) then
         write(lufile,'("mk5=net_protocol=tcp:4194304:2097152;")')
      endif

      if(km5A) then
        write(lufile,'(a)')   "mk5=dts_id?"
        write(lufile,'(a)')   "mk5=os_rev1?"
        write(lufile,'(a)')   "mk5=os_rev2?"
        write(lufile,'(a)')   "mk5=ss_rev1?"
        write(lufile,'(a)')   "mk5=ss_rev2?"
      else if(kflexbuff) then 
        write(lufile,'(a)')   "fb=dts_id?"
        write(lufile,'(a)')   "fb=os_rev?" 
      else if(km5B.or. km5c) then 
        write(lufile,'(a)')   "mk5=dts_id?"
        write(lufile,'(a)')   "mk5=os_rev?"
        write(lufile,'(a)')   "mk5=ss_rev?"      
      endif
      if(kflexbuff) then
        write(lufile,'(a)')   "fb_status"
      else if(km5a .or. km5b .or. km5c .or. km6disk) then
        write(lufile,'(a)')   "mk5_status"
      endif 

      if(cstrack_cap .eq. "DBBC3_DDC") then
        write(lufile,'(a)') "dbbc3=version"
      else if(kdbbc_rack) then
        write(lufile,'(a)') "dbbc=version "
      endif
      if(kfila10g_rack) then
        write(lufile,'(a)') "fila10g=version"
      endif 
           
      write(lufile,'(a)') "enddef"

      return
      end

