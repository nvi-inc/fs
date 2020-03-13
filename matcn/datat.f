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
      subroutine datat(imode,itran,ntr,lumat,kecho,lu,
     .  irecv,nrc,ierr,itimeout)
C 
C 1.1.   DATAT sends a data stream to the AT
C 
C     INPUT VARIABLES:
C 
C        IMODE  - mode of transmission, > 0 
C        NTR    - number of characters in transmission buffer 
      integer*2 itran(1)
C               - transmission buffer, all ready execpt for last char 
C        LUMAT  - LU of MAT daisy chain 
      logical kecho 
C               - true if terminal echo of communications is wanted 
C        LU     - unit for operator's terminal
C 
C     OUTPUT VARIABLES: 
C 
C        IERR   - error return
      integer*2 irecv(10) 
C               - buffer for response, if any 
C        NRC    - number of characters in response
C 
C     CALLING SUBROUTINES: MATCN
C 
C     CALLED SUBROUTINES: character utilities, IAT
C 
C 3.  LOCAL VARIABLES 
C 
      integer*2 lastch(4) 
C               - terminal characters, depending on mode
C        IVERIF - transmitted to AT for verification response 
C        IUPDAT - transmitted to AT for updating pending data 
C 
C 4.  CONSTANTS USED
C 
C 
C 5.  INITIALIZED VARIABLES 
C 
      data lastch/2h$/,2h**,2h& ,2h  / 
      data iverif/2h/ / 
      data iupdat/2h$ / 
C 
C 6.  PROGRAMMER: NRV (FROM ARW)
C     LAST MODIFIED:  800229
C  MWH 870911 Remove WVR-specific code
C 
C     PROGRAM STRUCTURE 
C 
C     1. Put the appropriate last character into the buffer.
C     Send buffer to AT via function IAT call.
C     If verification requested, get response and compare.
C     If update required, update and quit.
C 
      call ichmv(itran,ntr+1,lastch(imode+1),1,1) 
C 
      if(iat(itran,ntr+1,lumat,kecho,lu,irecv,nrc,ierr,itimeout).lt.0)  
     .return
      if (imode.eq.0.or.imode.eq.2.or.imode.eq.4) return
C 
      if (imode.ne.1) then
        if (iat(iverif,1,lumat,kecho,lu,irecv,nrc,ierr,itimeout).lt.0) 
     .     return
      endif
C 
      do i=1,ntr-2
        if (irecv(i).ne.itran(i+2)) then
          ierr = -6
          return
        endif
      enddo
C 
      if (imode.eq.1) idum=iat(iupdat,1,lumat,kecho,lu,
     .irecv,nrc,ierr,itimeout) 
C 
      return
      end 
