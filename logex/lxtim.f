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
      subroutine lxtim
C 
C LXTIM - Decodes specified start & stop times, or number of lines to 
C         list. Sets default parameters for listing starting at the 
C         first entry and ending at the last entry. 
C 
C MODIFICATIONS:
C 
C    DATE     WHO  DESCRIPTION
C    820325   KNM  SUBROUTINE CREATED 
C 
C RESTRICTIONS: Decodes the parameters for the LIST, PLOT, & SUMMARY
C               commands. 
C 
C COMMON BLOCKS USED: 
C 
      include 'lxcom.i'
C 
C    CALLING SUBROUTINES:  LOGEX - Main program 
C    Character Manipulation Utilities 
C    GTTIM - Decodes SNAP time format.
C    GTPRM - Parses the input buffer & gets the next parameter. 
C 
C LOCAL VARIABLES:
C 
      character cjchar
      character*79 outbuf
      integer answer, trimlen
      dimension iparm(2)
C        - registers for reading; parameters from GTPRM 
C        - REG, PARM - two word variables eqiv
C 
      equivalence (parm,iparm(1))
C 
C     ICH - Character counter.
C 
C  **************************************************************** 
C 
C  1.  Check for start time parameter. Set default for a start time 
C      if it was not given. 
C 
C  **************************************************************** 
C 
C 
      if (ikey.ne.12) goto 50
      if (iscn_ch(ibuf,1,nchar,'=').eq.0) goto 50
      call po_put_c('schedule summary does not accept start & stop times
     .')
      icode=-1
      goto 700
50    ich = ieq+1 
      call gtprm(ibuf,ich,nchar,1,parm, id) 
      if (cjchar(parm,1).ne.',') goto 100
C jan 1 1970
      its1 = 1
      its2 = 0
      its3 = 0
      goto 200
C 
C  Call GTTIM to decode the snap time format. 
C  Snap time format = 103022825 - day, hours, minutes, & seconds. 
C 
100   call gttim(ibuf,ieq+1,ich-2,0,its1,its2,its3,ierr) 
      if (ierr.ge.0) goto 200 
        outbuf='LXTIM10 - error sp '
        call ib2as(ierr,answer,1,4)
        call hol2char(answer,1,4,outbuf(20:))
        nchar = trimlen(outbuf) + 1
        outbuf(nchar:) = ' in start time.'
        call po_put_c(outbuf)
        icode=-1
        goto 700
C 
C NOT NEEDED ANYMORE, KEEP ITS1 AS IT WAS
C The following in-line function returns the day by calculating 
C (YR-1970)*1024+day. After December 31, 2002, this function
C will return a negative number. A lot longer now because we I*4
C on UNIX.
C 
200     continue
C       its1 = mod(its1,1024) 
C 
C 
C  ************************************************************ 
C 
C  2. # lines specified- If the next character is a # sign,   
C     then the next PARM specifies a limited number of lines      
C     to be listed or plotted. The number of lines specified  
C     is stored in NLINES.    
C 
C  ************************************************************ 
C 
C 
      if (cjchar(ibuf,ich).ne.'#') goto 400
C 
      ich = ich+1 
      call gtprm(ibuf,ich,nchar,1,parm,id) 
      if (iparm(1).gt.0) goto 300
      call po_put_c('LXTIM20 - error in number of lines specified.') 
      icode=-1
      goto 700
300   nlines = iparm(1)
      goto 700
C 
C 
C  *********************************************
C  3. Check for stop time if one was specified. 
C 
C  *********************************************
C 
C 
400   ic1 = ich 
      nlines = 0
      call gtprm(ibuf,ich,nchar,1,parm,id) 
      if (cjchar(parm,1).ne.',') goto 500
C not Y10K compliant
        ite1 = (2038-1970)*1024+1 
        ite2 = 0
        ite3 = 0
        goto 700
C 
C Call GTTIM to decode snap time format.
C 
500   call gttim(ibuf,ic1,ich-2,0,ite1,ite2,it3,ierr) 
C 
      if (ierr.ge.0) goto 600 
        outbuf='LXTIM30 - error sp '
        call ib2as(ierr,answer,1,4)
        call hol2char(answer,1,4,outbuf(20:))
        nchar = trimlen(outbuf) +1
        outbuf(nchar:) = ' in stop time.'
        call po_put_c(outbuf)
        icode=-1
        goto 700
C 
C NOT NEEDED ANYMORE
C Store calculated stop day in ITE1.
C 
600   continue
C     ite1 = mod(ite1,1024) 
C
700   continue
      return
      end 
