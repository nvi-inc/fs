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
      integer function ibin(iar,i)

C  THIS ROUTINE RETURNS THE BINARY VALUE FOUND 
C  IN THE I-TH BYTE(8 BITS/2 BYTES PER WORD)
C 
C  RESTRICTIONS - limits on use of routine
C 
C  REFERENCES - document cited
C 
C  NAME INTERFACE
C 
C  CALLING SEQUENCE: INT=IBIN(IAR,I)
C 
C  INPUT VARIABLES:
C 
C       IAR     - THE NAME OF THE STRING FROM WHICH THE INTEGER SHOULD BE 
C                 FOUND 
C 
C       I       - THE BYTE NUMBER IN THE STRING TO BE RETRIEVED(FROM 1) 
C 
        dimension iar(2)
C 
C       IAR     - THE SOURCE STRING FOR THE BINARY VALUE SOUGHT 
C 
C     OUTPUT VARIABLES: 
C 
C       IBIN    - THE INTEGER VALUE FOUND 
C 
C  COMMON BLOCKS USED 
C 
C       NONE
C 
C  DATA BASE ACCESSES 
C 
C       NONE
C 
C  EXTERNAL INPUT/OUTPUT
C 
C       NONE
C 
C   SUBROUTINE INTERFACE:
C 
C       THIS IS A UTILITY 
C 
C     CALLED SUBROUTINES: IAND
C 
C 3.  LOCAL VARIABLES 
C 
C     NONE
C 
C 4.  CONSTANTS USED
C 
C     NONE
C 5.  INITIALIZED VARIABLES 
C 
C     NONE
C 
C   PROGRAMMER: LEE N. FOSTER 
C   LAST MODIFIED:
C# LAST COMPC'ED  870407:12:46UT 19: 2:30.89
C 
C  DECIDE LEFT/RIGHT BYTE OF WORD
C 
      if (iand(i,1).ne.0) goto 500
C 
C  GET AND CONVERT FOR LEFT(OR HIGH) BYTE CASE 
C 
      ibin=(iand(iar(i/2),o'377')-o'60')
C 
      goto 900 
C 
C  GET AND CONVERT FOR RIGHT(OR LOW) BYTE CASE 
C
500   continue
      ibin=(iar((i+1)/2)/o'400')-o'60'
C 
C  EXIT ITS ALL OVER THIS ROUND
C 
900   continue

      return
      end 
