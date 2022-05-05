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
      subroutine gtprm(ibuf,ifc,iec,itype,parm,ierr)

C     get next parameter
C 
C        GTPRM parses the input buffer and returns the next parameter 
C 
C     INPUT VARIABLES:
C 
C        IFC,IEC- first, last characters to scan in buffer
C        ITYPE  - type of parameter expected: 
C                 0 - ASCII 
C                 1 - integer 
C                 2 - real
      integer*2 ibuf(1) 
C               - input string
C 
C     OUTPUT VARIABLES: 
C 
C        PARM   - parameter value found.
C                 If ASCII - up to 4 characters returned
C                 If integer - value is first word of PARM
C                 If real - value is PARM 
C                 If current value - * is returned
C                 If default - , is returned
C        IERR   - error return from ASCII to binary conversion
C        IFC    - points to first character beyond comma following parameter
C 
C     CALLING SUBROUTINES: QUIKR routines which accept parameters 
C 
C     CALLED SUBROUTINES: Lee's character routines: ISCNC,ICHMV,IAS2B,RAS2B 
C 
C 3.  LOCAL VARIABLES 
C 
      double precision das2b
      character cjchar

C        NCH    - number of characters up to the comma
C        ICOM   - character index of comma
C        VALUE  - decoded value, set to PARM on exit
      dimension ival(2) 
C               - integer equivalent of VALUE 
      equivalence (value,ival(1)) 
C 
C     PROGRAMMER: nrv 
C     LAST MODIFIED: 810422 
C 
C 
C     1. First scan for a comma and get the number of characters to decode. 
C     If the first character IFC is beyond the last character IEC, there
C     are no characters so indicate default value.
C 
      nargs = 6
      ierx = 0
C 
      parm = 0.0
C
C       skipping leading spaces
C
      do while(ifc.lt.iec)
        if(ichcm_ch(ibuf,ifc,' ').ne.0) goto 90
        ifc=ifc+1
      enddo
 90   continue
      if (ifc.le.iec) goto 100
      nch = 0 
      icom = ifc-1
      goto 210
100   icom = iscn_ch(ibuf,ifc,iec,',')
C                   Scan for a comma
      if (icom.eq.0) icom = iec+1 
C                   If no comma found, indicate beyond last character 
      nch = icom - ifc
      if (itype.eq.0) nch = min0(nch,4) 
C                   For ASCII values, take at most 4 characters only
C 
C 
C     2. Decide if default value was desired (i.e. no specification in
C     this field).  Also decide if current value was wanted (i.e. * was 
C     specified instead of value).
C 
      if (nch.gt.0) goto 250
210   continue 
      call char2hol(', ',ival,1,2)
      goto 900
C 
250   if (nch.gt.1.or.cjchar(ibuf,ifc).ne.'*') goto 300
      call char2hol('* ',ival,1,2)
      goto 900
C 
C 
C     3. For ASCII data, move characters into IVAL. 
C     For integer, decode into IVAL.
C     For real, decode into VALUE.
C 
300   if (itype.ne.0) goto 310
      call ifill_ch(ival,1,4,' ')  
      call ichmv(ival,1,ibuf,ifc,nch) 
C                   Move characters into output 
      goto 900
C 
310   if (itype.ne.1) goto 320
      ival(1) = ias2b(ibuf,ifc,nch)
      if (ival(1).eq.-32768) ierx = -1 
      goto 900
C 
320   if (itype.ne.2) goto 990
      value = das2b(ibuf,ifc,nch,ierx)
C 
900   parm = value
      ifc = icom+1
      if (nargs.gt.5) ierr = ierx 
990   return
      end 
