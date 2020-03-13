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
      subroutine lxist
C 
C LXIST - Writes the Log Output to a LU or Output file. 
C 
C MODIFICATIONS:
C 
C    DATE     WHO  DESCRIPTION
C    820326   KNM  SUBROUTINE CREATED 
C 
C    820416   KNM  THE LISTING OF A LOG CAN BE WRITTEN INTO AN OUTPUT 
C                  FILE IF THE OUTPUT COMMAND SPECIFIED A FILE NAME.
C 
C    820816   KNM  THE LOG IS NO LONGER WRITTEN OUT BY THIS ROUTINE.  
C                  LXIST CALLS LXWRT WHICH WRITES OUT THE LOG.
C 
C COMMON BLOCKS USED: 
C 
      include 'lxcom.i'
C 
C SUBROUTINE INTERFACES:
C 
C    CALLING SUBROUTINES:      LOGEX - Main program 
C    CALLED SUBROUTINES:
C 
C      LNFCH Utilities
C      LXWRT - Writes out LOGEX data
C 
C 
C  ************************************************************** 
C 
C  Call LXGET to read a log entry. If there is no error or end of 
C  listing write out IBUF.
C 
C  **************************************************************
C
C
      iout=0
      ilen=0
100   call lxget
      if (icode.eq.-1.or.lstend.eq.-1.or.ilen.lt.0) goto 200
      call lxwrt(ibuf,ilen)
      nlout=nlout+1
      goto 100
C
200   continue
      return
      end
