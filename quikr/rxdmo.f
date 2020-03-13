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
      subroutine rxdmo(ip,iclcm)
C  rx display <880617.0959>
C 
C     RXDMO gets data from the receiver and displays it 
C 
C     INPUT VARIABLES:
C 
      dimension ip(1) 
C        IP(1)  - class number of buffer from MATCN 
C        IP(2)  - # records in class
C        IP(3)  - error return from MATCN 
C        IP(4)  - who, or o'77' (?) 
C        IP(5)  - class with command
C 
C     OUTPUT VARIABLES: 
C 
C        IP(1) - error
C        IP(2) - class
C        IP(3) - number of records
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
C 
      include '../include/fscom.i'
C 
C 2.5   CALLED SUBROUTINES: RXVTOT, character utilities
C 
C 3.  LOCAL VARIABLES 
C 
C     IAD - A/D channel 
C     IDCAL - delay cal heater
C     ICAL - cal status 
cxx      dimension lc(3) 
      integer*2 lc(3), iadc, iad
C     IBOX - box heater 
C     ILO - LO status 
C     NCH    - character counter
C
      integer*2 lunlk(4)
      logical kcom,kdata
      dimension ireg(2)          ! registers from exec
      integer get_buf
      equivalence (reg,ireg(1)) 
      integer*2 ibuf1(20),ibuf2(30) 
C               - input class buffers, output display buffer
C 
C 4.  CONSTANTS USED
      parameter (ilen=40, ilen2=60)     !  buffer lengths, characters
C 
C 5.  INITIALIZED VARIABLES 
C 
      data lunlk /2hun,2hlo,2hck,2hed/  
cxx lunlk=unlocked
C 
C 6.  PROGRAMMER: NRV  CREATED 830610 AT MOJAVE 
C 
C     WHO  WHEN    WHAT 
C     WEH  830617  ADDED LOOKUP TABLE FOR 20K NOISE DIODE 
C                  FIXED TO DISPLAY EXACTLY 4 SIGNIFICANT DIGITS
C     NRV  840509  MADE CHANGES FOR NEW VERSION 
C                  USE SAME TABLE FOR 70K AS FOR 20K
C                  PRESSURE FORMULA FROM BEC
C     MWH  850121  PUT 'UNLOCKED' MESSAGE IN INVERSE VIDEO
C     LAR  880227  MOVE VOLTAGE-TO-WEATHER CONVERSION TO RXVTOT
C     NRV  921020  Add fs_get calls
C 
C 
C     1. Determine whether parameters from COMMON wanted and skip to
C     response section. 
C     Get RMPAR parameters and check for errors from our I/O request. 
C 
      kcom = (ichcm_ch(ip(4),1,'?').eq.0)
C 
      iclass = ip(1)
      ncrec = ip(2) 
      ierr = ip(3)
C 
      if (.not.kcom.and.(ierr.lt.0.or.iclass.eq.0.or.iclcm.eq.0)) return
      ierr=0
C 
C     2. Get class buffer with command in it.  Set up first part
C     of output buffer.  Get buffer from MATCN. 
C 
      ireg(2) = get_buf(iclcm,ibuf2,-ilen2,idum,idum)
C 
      nchar = ireg(2) 
      nch = iscn_ch(ibuf2,1,nchar,'=')
      kdata = nch.eq.0
C                   If our command was only "device" we are waiting for 
C                   data and know what to expect. 
      if (nch.eq.0) nch = nchar+1 
C                   If no "=" found, position after last character
      nch = ichmv_ch(ibuf2,nch,'/')    ! put "/" to indicate a response
C 
      if (.not.kcom) then
        if (.not.kdata) then
          do i=1,ncrec
            if (i.ne.1) nch=mcoma(ibuf2,nch)
C                   If not first parm, put comma before 
            ireg(2) = get_buf(iclass,ibuf1,-ilen,idum,idum)
            nchar = ireg(2)
            nch = ichmv(ibuf2,nch,ibuf1(2),1,nchar-2)
C                   Move buffer contents into output list 
          enddo
          goto 500
        endif
C 
        ireg(2) = get_buf(iclass,ibuf1,-ilen,idum,idum)
        call ma2rx(ibuf1(2),lostrx,ical,idcal,ibox,iadc,vadc)
      else
        idum=ichmv(iadc,1,iadcrx,1,2)
        ical = lswcal                ! read values from field system common
        idcal = idchrx
        ibox = ibxhrx
      endif
      ierr = 0
      ia = 1 + ia22h(iadc)
C
C     3. Now the buffer contains: RX/, and we want to add the data. 
C 
      call char2hol('-1',iad,1,2)
      idumm1 = ichmv_ch(lc,1,'undef')
      nl = 5
      if (ia.ne.0) then
        nl = iflch(rxlcode(1,ia),6)
        idum=ichmv(iad,1,iadc,1,2)
        idumm1 = ichmv(lc,1,rxlcode(1,ia),1,nl) 
      endif
      nch = ichmv(ibuf2,nch,iad,1,2)
      nch = ichmv_ch(ibuf2,nch,'(') 
      nch = ichmv(ibuf2,nch,lc,1,nl)  
      nch = ichmv_ch(ibuf2,nch,')') 
      nch = mcoma(ibuf2,nch)
      if (idcal.eq.0) nch = ichmv_ch(ibuf2,nch,'off')
      if (idcal.eq.1) nch = ichmv_ch(ibuf2,nch,'on') 
      nch = mcoma(ibuf2,nch)
      if (ibox.eq. 0) nch = ichmv_ch(ibuf2,nch,'off')
      if (ibox.eq. 1) nch = ichmv_ch(ibuf2,nch,'a')    
      if (ibox.eq.-1) nch = ichmv_ch(ibuf2,nch,'b')    
      nch = mcoma(ibuf2,nch)
      do i=1,3
        if (ifamrx(i).eq.0) nch=ichmv_ch(ibuf2,nch,'off')  
        if (ifamrx(i).eq.1) nch=ichmv_ch(ibuf2,nch,'on')   
        nch=mcoma(ibuf2,nch)
      enddo
      if (ical.eq. 0) nch = ichmv_ch(ibuf2,nch,'off')
      if (ical.eq. 1) nch = ichmv_ch(ibuf2,nch,'on') 
      if (ical.eq. 2) nch = ichmv_ch(ibuf2,nch,'ext')
      if (ical.eq.-1) nch = ichmv_ch(ibuf2,nch,'oon')
      if (ical.eq.-2) nch = ichmv_ch(ibuf2,nch,'ooff') 
      if (kcom) goto 500
      nch = mcoma(ibuf2,nch)
      if (lostrx.eq.1) nch=ichmv_ch(ibuf2,nch,'locked')
      if (lostrx.eq.0) nch=ichmv(ibuf2,nch,lunlk,1,8)
      nch = mcoma(ibuf2,nch)
C
C   CONVERT VOLTAGE TO TEMPERATURE OR BAROMETRIC PRESSURE
C 
      call rxvtot(ia,vadc,vadcrx)
C 
C   CONVERT TO ASCII, PUT THE NUMBER OF CHARACTERS INTO A DUMMY VARIABLE 
C 
      nchb= nch + ir2as(vadcrx,ibuf2,nch,10,3)  
C 
C   PUT ONLY 4 SIGNIFICANT DIGITS + A DECIMAL POINT (+ A MINUS  
C                                   SIGN IF NEGATIVE) 
C   THIS IS MADE SIMPLE BY THE FACTS THAT IR2AS LEFT JUSTIFIES
C   AND THAT ALL THE NUMBERS WE WORK HAVE THE LEAST SIGNIFICANT 
C   DIGIT TO THE LEFT OF THE .0001 DECIMAL PLACE
C   OTHERWISE WE WOULD NEED LOGS OR SOMETHING 
C 
      nch = nch + 5 
      if (vadcrx.lt.0) nch=nch+1 
C 
C     5. Now send the buffer to BOSS for logging. 
C 
500   iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf2,-nch,'fs','  ')
C 
      ip(1) = iclass 
      ip(2) = 1 
      ip(3) = ierr
      call char2hol('qb',ip(4),1,2)
      ip(5) = 0 
      return
      end 
