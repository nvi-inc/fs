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
      subroutine lxwrt(ibufx,ncharx)
C
C LXWRT - Writes LOGEX output to the terminal or output file.
C
C MODIFICATIONS:
C
C    DATE     WHO  DESCRIPTION
C    820819   KNM  SUBROUTINE CREATED
C
C RESTRICTIONS:
C
C INPUT VARIABLES:
C
      integer*2 ibufx(1)
      integer*2 ncharx
      integer nwx
C
C     NCHARX - Number of characters in the output buffer.
C
C COMMON BLOCKS USED:
C
      include 'lxcom.i'
C
C SUBROUTINE INTERFACES:
C    CALLING SUBROUTINES:
C
C      LOGEX - Main program
C      LXSUM - Summary command
C      READL - Get next observation from the log for the Summary
C      LXTPL - Strip-chart plotting routine
C      LXOPN - Opens log file
C      LXIST - List log file
C
C    CALLED SUBROUTINES:
C      LNFCH Utilities
C
C LOCAL VARIABLES:
C
      integer fmpwrite2, trimlen
      integer nchar, answer
      character*79 outbuf
C        - Output buffer to write out
C
C
C *********************************************************
C
C 1. Put a blank after the last character in the output
C    buffer in case we have an odd number of characters
C    to write out. Then test for whether the output is
C    to be written to the terminal or the output file.
C
C **********************************************************
C
C
      nwx=ncharx
      if (MOD(nwx,2).eq.1) then
        nwx=nwx+1
        idum=ichmv_ch(ibufx,nwx,' ')
      endif
      if (iterm.ne.1) goto 100
        call po_put_i(ibufx,nwx)
      goto 900
C
C Buffer is written to the output file here.
C
100   if(iout.eq.1) goto 150
        call po_put_c('***output file is being processed***')
        iout=1
150   continue 
      id = fmpwrite2(jdcb,ierr,ibufx,nwx)
      if (ierr.lt.0) then
        outbuf='LXWRT - error '
        call ib2as(ierr,answer,1,4)
        call hol2char(answer,1,4,outbuf(15:))
        nchar = trimlen(outbuf) + 1
        outbuf(nchar:)=' writing to output file'
        call po_put_c(outbuf)
        icode=-1
      end if
C
900   continue
      return
      end
