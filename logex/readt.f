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
      subroutine readt(ibufsk,iskbw,lstid,lsn,iyr,idayr,ihr,min,isc,idur
     .,nstn)
C
C READT - Get the next observation that the station participates in the
C         schedule.
C
C MODIFICATIONS:
C
C    DATE     WHO  DESCRIPTION
C    820513   KNM  SUBROUTINE CREATED
C
C INPUT VARIABLES:
C
      integer*2 ibufsk(80)
C        - Buffer for schedule file
C
C     ISKBW - Number of words in IBUFSK.
C
C     LSTN - The station id.
C
C OUTPUT VARIABLES:
C
      integer*2 lsn(4)
C        - Contains the schedule entry source name.
C
C     ICODE - Error flag.
C
C COMMON BLOCKS USED:
C
      include 'lxcom.i'
C
C SUBROUTINE INTERFACES:
C
C    CALLING SUBROUTINES:
C
C      LXSUM - SUMMARY command.
C
C    CALLED SUBROUTINES:
C
C      UNPSK - Unpacks the record found in IBUFSK and puts the data
C              into the output variables.
C      File manager package routines.
C
C LOCAL VARIABLES:
C
      character*79 outbuf
      integer answer, trimlen
      integer fmpread
      integer*2 lst(10)
C        - Station ids
C
C
C ******************************************************************
C
C 1. The $SKED file entry. Then call UNPSK to put the data into out-
C    put variables.  Check to see if the station was scheduled for
C    an observation.
C
C ******************************************************************
C
C
      call ifill_ch(lsn,1,8,' ')
cxx100   if(ifbrk(idum).lt.0) goto 275
100   call ifill_ch(ibufsk,1,160,' ')
      id = fmpread(idcbsk,ierr,ibufsk,iskbw*2)
      ilensk = iflch(ibufsk,iskbw*2)
      if (ierr.lt.0) then
        outbuf='READT10 - error '
        call ib2as(ierr,answer,1,4)
        call hol2char(answer,1,4,outbuf(17:))
        nchar = trimlen(outbuf) + 1
        outbuf(nchar:)=' reading schedule file'
        call po_put_c(outbuf)
        goto 275
      end if
150   if (iscn_ch(ibufsk,1,1,'$').ne.0) goto 275
      if (ilensk.lt.0) goto 275
      call unpsk(ibufsk,iskbw,lsn,lst,iyr,idayr,ihr,min,isc,idur,nstn)
      itsc2=ihr*60+min
      if (idayr.lt.itsk1.or.(idayr.eq.itsk1.and.itsc2.lt.itsk2)) 
     .   goto 100
      do i=1,nstn
        if (lstid.eq.lst(i)) goto 250
      enddo
      goto 100
250   if (idayr.lt.itske1.or.(idayr.eq.itske1.and.itsc2.le.itske2))
     .goto 300
      ierr=0
      call fmprewind(idcbsk,ierr)
      if (ierr.ne.0) then
        outbuf='READT20 - error '
        call ib2as(ierr,answer,1,4)
        call hol2char(answer,1,4,outbuf(17:))
        nchar = trimlen(outbuf) + 1
        outbuf(nchar:)=' rewinding schedule file'
        call po_put_c(outbuf)
      end if
275   icode=-1
C
300   continue
      return
      end
