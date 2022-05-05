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
      function iscns(input,icst,icen,icomp,icomst,nch)

! AEM 20050112 add implicit none, list variables
      implicit none

      integer iscns,icst,icen,icomst,nch

C
C  ISCNS scans a string for the occurence of another string 
C 
C  ISCNS INTERFACE 
C 
C  INPUT VARIABLES:
C 
C        ICST   - starting character in INPUT 
C        ICEN   - last character in INPUT 
C        ICOMST - starting character in ICOMP 
C        NCH    - number of characters to compare 
      integer*2 input(*),icomp(*)
C               - input string array, compare string array
C 
C  OUTPUT VARIABLES: 
C 
C        ISCNS - returns character in INPUT at which compare
C                string ICOMP begins
C 
C  SUBROUTINE INTERFACE:
C 
C  CALLING SUBROUTINES: utility
C  CALLED SUBROUTINES: ISCNC, ICHCM, JCHAR from Lee's package
C
C  LOCAL VARIABLES 
C 
C        ICH    - general character counter 
C        ISC    - character found in scan 
C 
C  PROGRAMMER: NRV 
C  LAST MODIFIED:
C# LAST COMPC'ED  870407:12:47 #
C 
C  SCAN FOR THE OCCURENCE OF THE FIRST CHARACTER IN ICOMP
C

      integer ich,isc
      integer iscnc,ichcm,jchar

      ich = icst
100   if (icen-ich+1.ge.nch) goto 101
      isc = 0 
      goto 990
101   continue
      isc = iscnc(input,ich,icen,jchar(icomp,icomst))
C 
C  IF THIS CHARACTER NOT FOUND, RETURN ZERO FOR NO MATCH 
C 
      if (isc.eq.0) goto 990
C 
C  NOW COMPARE THE INPUT STRING WITH THE COMPARE STRING
C 
      ich = ichcm(input,isc,icomp,icomst,nch) 
C 
C  IF THE STRINGS MATCH WE ARE DONE, SO RETURN THE STARTING CHARACTER
C 
      if (ich.eq.0) goto 990
C 
C  UPDATE THE FIRST CHARACTER TO USE IN THE SCAN AND LOOP BACK 
C 
      ich = isc + 1 
      goto 100
C 
990   iscns = isc 

! AEM 20050112 commented return
!      return
      end 
