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
      function numsc(ias,ifc,iec,frac)
C 
C  NUMSC scans an ASCII string and returns integer and fraction 
C 
C  CALLING SEQUENCE: CALL NUMSC(III,III,...,OOO,OOO,...)
C 
C  INPUT VARIABLES:
C 
C        IFC    - first character in string to be scanned 
C        IEC    - last character in string to be scanned
      dimension ias(1)
C               - ASCII string to be scanned
C 
C  OUTPUT VARIABLES: 
C 
C        FRAC   - fractional part, if any, found in string
C        NUMSC  - integer part of number
C 
C  CALLING SUBROUTINES:
C  CALLED SUBROUTINES: IAS2B,ISCNC 
C 
C  LOCAL VARIABLES 
C 
C        IDC    - character index of decimal point
C 
C  PROGRAMMER: nrv 
C  LAST MODIFIED:   781206 
C# LAST COMPC'ED  870407:12:43 #
C 
C  First find the decimal point, if any.
C  Then decode the integer part of the number. 
C  Finally decode the fraction, if any.
C 
      idc = iscn_ch(ias,ifc,iec,'.')
      if (idc.eq.0) idc = iec + 1 
      numsc = ias2b(ias,ifc,idc-ifc)
      frac = 0.0
      if (idc.eq.iec+1) goto 99 
      frac = ias2b(ias,idc+1,iec-idc) 
      frac = frac/(10.0**(iec-idc)) 

99    return
      end 
