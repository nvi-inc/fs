*
* Copyright (c) 2020, 2023, 2025 NVI, Inc.
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
      subroutine pfcop(lp,lui,iret)
C
C 1.  PFCOP PROGRAM SPECIFICATION
C
C 1.1.   PFCOP copies a procedure library into scratch file 3.
C
C 1.2.   RESTRICTIONS - Only procedure libraries are accessible.  These have
C        the prefix "[PRC" which is transparent to the user.  Procedures are
C        available only on disc ICRPRC.
C
C 1.3.   REFERENCES - Field system manual
C
C 2.  PFCOP INTERFACE
C
C 2.1.   CALLING SEQUENCE: CALL PFCOP(LP,LUI,IRET)
C
C     INPUT VARIABLES:
C
      character*(*) lp
C                - target procedure library
C        LUI     - terminal LU
C
C 2.2.   COMMON BLOCKS USED:
C
      include '../include/params.i'
      include 'pfmed.i'
C
C 2.3.   DATA BASE ACCESSES: none
C
C 2.4.   EXTERNAL INPUT/OUTPUT
C
C     INPUT VARIABLES: none
C
C     OUTPUT VARIABLES:
      integer iret   !
C
C     TERMINAL   - error message
C
C 2.5.   SUBROUTINE INTERFACE:
C
C     CALLING SUBROUTINES: PFMED, FFM, FFMP, FED
C
C     CALLED SUBROUTINES: FMP routines, IB2AS, EXEC, PFBLK
C
C 3.  LOCAL VARIABLES:
C
      character*4 lfr
C                - correct extension with leading dot for reading
      character*64 pathname,link
      integer trimlen
      logical kex,kerr
C
C 4.  CONSTANTS USED
C
C 5.  INITIALIZED VARIABLES: none
C
C 6.  PROGRAMMER: C. Ma
C     LAST MODIFIED: <910322.0337>
C# LAST COMPC'ED  870115:05:40
C
C     PROGRAM STRUCTURE
C
C     Check if procedure library exists to be copied.
      if(lp.eq.'    ') then
C     No procedure library - message and return.
         write(6,*) 'pfcop: no procedure library active'
         iret = -1
         return
      else
        iret = 0
        call pfblk(1,lp,lfr)
        nch = trimlen(lp)
        if (nch.le.0) then
           write(6,*) 'pfcop: illegal filename length'
           iret=-1
           return
        else
           call follow_link(lp(:nch),link,ierr)
           if(ierr.ne.0) then
              iret=-1
              return
           endif
           if(link.ne.' ') then                 
              if(lfr(:4).eq.'.prx') then
                 iprc=index(link,".prc")
                 link(iprc+3:iprc+3)='x'
              endif
              pathname = FS_ROOT//'/proc/' // link(:trimlen(link))
           else
              pathname = FS_ROOT//'/proc/'//lp(:nch)//lfr(1:4)
           endif
        endif
C     Open procedure library.
        inquire(file=pathname,exist=kex)
        if (.not.kex) then
          nch = trimlen(pathname)
          if (nch.gt.0) write(lui,9200) pathname(1:nch)
9200      format(" pfcop file ",a," does not exist!!")
          iret = -1
        else
           pathsave=' '
           lpsave=' '
          call fclose(idcb3,ierr)
          if(kerr(ierr,'pfcop','closing',' ',0,0)) then
             iret=-1
             return
          endif
          call fopen(idcb3,pathname,ierr)
          if(kerr(ierr,'pfcop','opening',pathname,0,1)) then
             iret=-1
             return
          endif
C The last parameter tells KERR to ignore all positive IERR's
           pathsave=pathname
           lpsave=lp
        end if
      end if

      return
      end
