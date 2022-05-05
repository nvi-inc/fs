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
      REAL*4 FUNCTION RAS2B(IAS,IC1,NCH,IERR)
C
C     THIS FUNCTION CONVERTS AN ASCII STRING TO REAL
C
      implicit none

C  INPUT PARAMETERS:
      integer*2 IAS(1)
      integer ic1,nch
C       INPUT STRING WITH ASCII CHARACTERS
C     IC1 - FIRST CHARACTER TO USE IN IAS
C     NCH - NUMBER OF CHARACTERS TO CONVERT
C
C  OUTPUT:
      integer ierr
C     IERR - ERROR RETURN, 0 IF OK, -1 IF ANY CHARACTER IS NOT A NUMBER
C
C  LOCAL VARIABLES
C
      double precision das2b
C
      ras2b=das2b(ias,ic1,nch,ierr)
C
      return
      end




