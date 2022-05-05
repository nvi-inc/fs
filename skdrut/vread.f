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
      subroutine VREAD(cbuf,cfile,lu,iret,ivexnum,ierr)

C     VREAD calls the routines to read a VEX file.
C  Called by sked and drudg. Reads sections for experiment,
C  sources, stations, and modes. 

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/statn.ftni'

C History
C 960522 nrv New.
C 970114 nrv Stop if the supported VEX version is not found.
C 970124 nrv Add a call to VGLINP, and a call to errormsg
C 990921 nrv Save the VEX version number.
C 020619 nrv Add call to VPRINP to read scheduling parameters
! 2010.05.16 JMG. Got rid of trailing char(0) on some output
! 2019.08.14 JMG  Set 'iret=0' after reading exper. this prevents
!             announcing error after return from vread 

C Input
      character*(*) cfile ! VEX file path name
      integer lu
      character*(*) cbuf ! buffer with first line of VEX file in it

C Output
      integer iret ! error return from VEX routines
      integer ierr ! error return, non-zero
      integer ivexnum

C Local
      integer fvex_open,ptr_ch
      integer i,trimlen

      i=trimlen(cbuf)
      write(lu,'("VREAD01 -- Got a VEX file to read, ",a".")') 
     .cbuf(1:i)
      vex_version = cbuf(i-3:i-1)
C     if (vex_version.ne.'1.5'.and.vex_version.ne.'1.6') then
      if (vex_version.ne.'1.5') then
C       write(lu,'("VREAD02 -- Only versions 1.5 and 1.6 are ",
        write(lu,'("VREAD02 -- Only version 1.5 is ",
     .  "supported, sorry.")')
        return
      endif
      
C  1. Open the file

      ierr=1
      call null_term(cfile)
      iret = fvex_open(ptr_ch(cfile),ivexnum)
      if (iret.ne.0) return

C  2. Read the sections

      write(lu,'("$EXPER")') 
      call vglinp(ivexnum,lu,ierr,iret) ! global info
      if (ierr.ne.0) then
        write(lu,'("VREAD00 - Error reading experiment info.")')
        call errormsg(iret,ierr,'EXPER',lu)
      endif
      iret=0
  
      write(lu,'("$STATIONS")') 
      call vstinp(ivexnum,lu,ierr) ! stations
      if (ierr.ne.0) then
        write(lu,'("VREAD01 - Error reading stations.")')
      endif
      write(lu,'("$MODES")')
      call vmoinp(ivexnum,lu,ierr) ! modes
      if (ierr.ne.0) then
        write(lu,'("VREAD02 - Error reading modes.")')
      endif
      write(lu,'("$SOURCES")') 
      call vsoinp(ivexnum,lu,ierr) ! sources 
      if (ierr.ne.0) then
        write(lu,'("VREAD03 - Error reading sources.")')
      endif
C -------------------------------------------
C     call vobinp(ivexnum,lu,iret,ierr,scan_id) ! observations
C     if (ierr.ne.0) then
C       il=trimlen(scan_id)
C       write(lu,'("VREAD04 - Error from vobinp=",
C    .      i5,", iret=",i5,", scan#=",a)') ierr,iret,scan_id(1:il)
C       call errormsg(iret,ierr,'SCHED',lu)
C     endif
C     write(lu,'("  Total number of scans in this schedule: ",
C    .i5)') nobs
C -------------------------------------------

C  3. Initialize parameters to standard values. These
C     are parameters not read in from the astro vex file.
C     Early start, late stop, and time gap were read in.

      isettm = 20
      ipartm = 70
      itaptm = 1
      isortm = 5
      ihdtm = 6

C 3. Read the $SCHEDULING_PARAMS section to get parameters.
C    If there is a def for SKED_PARAMS then mark this as a
C    sked-produced schedule by setting ksked true.
C     call vprinp(ivexnum,lu,ierr) ! params
C     if (ierr.ne.0) then
C       write(lu,'("VREAD05 - Error reading parameters by vprinp.")')
C     endif

      return
      end
