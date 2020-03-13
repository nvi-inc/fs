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
      subroutine gtfld(ias,ic1,ic2,ifc,iec) 

C     SCAN A STRING FOR A SERIES OF CHARACTERS SEPARATED BY BLANKS
C 
C     INPUT VARIABLES:
C 
      dimension ias(1)
C                   INPUT STRING WITH CHARACTERS
C     IC1 - FIRST CHARACTER TO USE IN IAS 
C     IC2 - LAST  CHARACTER TO USE IN IAS
C 
C     OUTPUT VARIABLES: 
C 
C     IFC - FIRST NON-BLANK CHARACTER IN IAS
C     IEC - LAST NON-BLANK CHARACTER IN IAS 
C 
C     LOCAL VARIABLES:
      character cjchar
C 
C     IC1 - LAST CHARACTER IN IAS TO USE
C 
C 
C     FIRST INITIALIZE
C 
      ifc = 0 
      iec = 0 
      if (ic1.gt.ic2) return
C 
C     SCAN FOR THE FIRST NON-BLANK
C 
      do 100 i=ic1,ic2
        ix=i
        if (char(jchar(ias,i)).ne.' ') goto 101 
100     continue
      return
C                   THERE ARE ONLY BLANKS 
101   ifc = ix 
      iec = ix 
      if (iec.lt.ic2) goto 190
      ic1 = ic2 + 1 
      return
C 
C     NOW SCAN FOR THE NEXT BLANK 
C 
190   do 200 i=ifc+1,ic2
        ix=i
        if (char(jchar(ias,i)).eq.' ') goto 201 
200   continue
      iec = ic2 
C                   STRING ENDS WITH NON-BLANK
      ic1 = ic2 + 1 
      return
201   iec = ix-1 
      ic1 = ix 
C                   UPDATE FIRST CHARACTER NUMBER IN STRING 
      return
      end 
