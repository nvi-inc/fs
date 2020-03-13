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
      subroutine ifdis(ip,iclcm,kfirst)
C  if distributor display <880922.1239>
C 
C 1.1.   IFDIS gets data from the IF distributor and displays it
C 
C 2.  IFDIS INTERFACE 
C 
      dimension ip(1) 
C     INPUT VARIABLES:
C        IP(1)  - class number of buffer from MATCN 
C        IP(2)  - number of records in class
C        IP(3)  - error return from MATCN 
C        IP(4)  - 
C        ICLCM  - class number of command buffer
C 
C     OUTPUT VARIABLES: 
C        IP(1) - CLASS
C        IP(2) - # RECS 
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
      include '../include/fscom.i'
C 
C 2.5.   SUBROUTINE INTERFACE:
C
      logical kfirst
c
C     CALLING SUBROUTINES: IFD
C     CALLED SUBROUTINES: character utilities 
C 
C 3.  LOCAL VARIABLES 
      integer*2 ibuf(30)                    ! input class buffer
      integer*2 ibuf2(30)                   ! output display buffer
      integer*2 itp(10)                     ! buffer for ! data with tp
      logical kcom,kdata
      dimension ireg(2)                     ! registers from exec calls
      integer get_buf
      equivalence (reg,ireg(1)) 
      integer nch                           ! character counter
C 
C 4.  CONSTANTS USED:
      parameter (ilen=60)                   ! length of buffers, characters
C 
C     PROGRAMMER: NRV
C     LAST MODIFIED: 800215 
C 
C     PROGRAM STRUCTURE 
C 
C     1. First check error return from MATCN.  If not 0, get out
C     immediately.
C 
C 
      kcom = (ichcm_ch(ip(4),1,'?').eq.0)
C 
      iclass = ip(1)
      ncrec = ip(2) 
      ierr = ip(3)
      nrec = 0
C 
      if (.not.kcom .and. (ierr.lt.0 .or. iclass.eq.0 .or. iclcm.eq.0))
     : return
C 
C     2. Get class buffer with command in it.  Set up first part
C     of output buffer.  Get first buffer from MATCN. 
C 
      ireg(2) = get_buf(iclcm,ibuf2,-ilen,idum,idum)
C 
      nchar = ireg(2) 
      nch = iscn_ch(ibuf2,1,nchar,'=')
      kdata = (nch.eq.0).or..not.kfirst
C                   If our command was only "device" we are waiting for 
C                   data and know what to expect. 
      if (nch.eq.0) nch = nchar+1 
C                   If no "=" found, position after last character
      nch = ichmv_ch(ibuf2,nch,'/')         ! put / to indicate a response
C 
      if (.not.kcom .and. .not.kdata) then
        do i=1,ncrec
          if (i.ne.1) nch=mcoma(ibuf2,nch)      ! commas separate parameters
          ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
          nchar = ireg(2)
          nch = ichmv(ibuf2,nch,ibuf(2),1,nchar-2)
C                   Move buffer contents into output list 
        enddo
      else
        if (kcom) then
          call fs_get_iat1if(iat1if)
          ia1 = iat1if
          call fs_get_iat2if(iat2if)
          ia2 = iat2if
          in1 = inp1if
          in2 = inp2if
        else
          ireg(2) = get_buf(iclass,itp,-10,idum,idum)
          ireg(2) = get_buf(iclass,ibuf,-10,idum,idum)
C 
C     3. Now the buffer contains: IFD=, and we want to add the data.
C 
          call ma2if(ibuf,itp,ia1,ia2,in1,in2,tp1ifd,tp2ifd,iremif)
        endif
C 
        ierr = 0
        nch = nch + ib2as(ia1,ibuf2,nch,o'100000'+2)   ! 1st attenuator setting
        call fs_get_iat1if(iat1if)
        if (ia1.ne.iat1if) ierr = -301
        nch = mcoma(ibuf2,nch)
        nch = nch + ib2as(ia2,ibuf2,nch,o'100000'+2)   ! 2nd attenuator setting
        call fs_get_iat2if(iat2if)
        if (ia2.ne.iat2if) ierr = -302
        nch = mcoma(ibuf2,nch)
        nch = iifed(-1,in1,ibuf2,nch,ilen)           ! encode if1 input
        if (in1.ne.inp1if) ierr = -303
        nch = mcoma(ibuf2,nch)
        nch = iifed(-1,in2,ibuf2,nch,ilen)           ! encode if2 input
        if (in2.ne.inp2if) ierr = -304
C 
        if (.not.kcom) then
          nch = mcoma(ibuf2,nch)
          nch = iifed(-2,iremif,ibuf2,nch,ilen)      ! encode remote/local
          nch = mcoma(ibuf2,nch)
          nch = nch + ir2as(tp1ifd,ibuf2,nch,6,0) - 1
          nch = mcoma(ibuf2,nch)
          nch = nch + ir2as(tp2ifd,ibuf2,nch,6,0) - 1
        endif
      endif
C 
C     5. Now send the buffer to SAM and schedule PPT. 
C 
      iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf2,-nch,'fs','  ')
      if (.not.kcheck) ierr = 0 
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = ierr
      call char2hol('qi',ip(4),1,2)

      return
      end 
