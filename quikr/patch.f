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
      subroutine patch(ip)
C 
C     PATCH sets up the common array IFP2VC 
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of input parameter buffer. 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - CLASS
C        IP(2) - # REC
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C   COMMON BLOCKS USED
      include '../include/fscom.i'
C 
C     CALLED SUBROUTINES: GTPRM
C 
C   LOCAL VARIABLES 
C        NCHAR  - number of characters in buffer
C        ICH    - character counter 
      dimension ifp(16) 
C               - temporary holder for decoded Patching.
C        ICHNL  - channel number
C        IVC    - VC number 
C        IVL    - -1 for Lo, +1 for High
      integer*2 ibuf(40)
C               - class buffer
C        ILEN   - length of IBUF, chars 
      dimension iparm(2)
C               - parameters returned from GTPRM
      dimension ireg(2) 
      integer get_buf,ichcm_ch
C               - registers from EXEC calls 
C 
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1)) 
C 
C  INITIALIZED VARIABLES
      data ilen/80/ 
C 
C  PROGRAMMER: NRV & MAH
C     CREATED: 820310 
C 
C 
C     1. If we have a class buffer, then we are to set the
C     variables in common for PCALR to use. 
C 
      iclcm = ip(1) 
      do i=1,3
        ip(i) = 0
      enddo
      call char2hol('qq',ip(4),1,2)
      ichold = -99
      if (iclcm.eq.0) then
        ip(3) = -1
        return
      endif
      call ifill_ch(ibuf,1,ilen,' ')
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2) 
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0) then
        call padis(ip,iclcm)
        return
      endif
      if (cjchar(ibuf,ieq+1).eq.'?') then
        ip(1) = 0
        ip(4) = o'77'
        call padis(ip,iclcm)
        return
      endif
C
C     2. Step through buffer getting each parameter and decoding it.
C     Command from user has these parameters:
C        PATCH=<LO#>,<VC#H(or L)>,<VC#H(or L)>,.........
C     Choices are <LO#>: LO1, LO2, or LO3, no default
C                 <VC#H(or L)>  : no default, must be at least one
C
C     2.1 FIRST PARM, LO NUMBER
C
      ich = 1+ieq
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).eq.',') then
         do i=1,16
            ifp2vc(i) = 0
         enddo
        call fs_set_ifp2vc(ifp2vc)
        return
      else if(ichcm_ch(parm,1,'lo').ne.0) then
        ip(3) = -201
      else
        ichnl = ias2b(parm,3,1)
        if (ichnl.lt.1 .or. ichnl.gt.3) ip(3)= -201
      endif
      if (ip(3).eq.-201) return
C 
C     2.2  2nd and subsequent parms, VC#, H or L. 
C 
      ifc = 0
      call fs_get_ifp2vc(ifp2vc)
      do i=1,16 
        ifp(i) = ifp2vc(i)
      enddo
C
C  Loop through until end of input, then exit.
C
      call fs_get_rack(rack)
 300  isave=ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).eq.',') then
        if (ifc.le.0) then
          ip(3) = -102
        else                          !  set up the common array now
          do i=1,16
            ifp2vc(i) = ifp(i)
          enddo
        endif
        call fs_set_ifp2vc(ifp2vc)
        return
      endif
      nch = 2 
      if(MK3.eq.rack.or.MK4.eq.rack.or.LBA4.eq.rack) then
         if (cjchar(parm,3).eq.' ') nch = 1 
         ivc = ias2b(parm,1,nch) 
         if (ivc.lt.1 .or. ivc.gt.14) ip(3)= -202
         if (cjchar(parm,nch+1).ne.'h' .and.cjchar(parm,nch+1).ne.'l')
     :        ip(3) = -203
         if (ip(3).lt.0) return
         ivl = 1
         if (cjchar(parm,nch+1).eq.'l') ivl = -1 
         ifp(ivc) = ivl*ichnl
      else if(K4.eq.rack.or.K4MK4.eq.rack.or.K4K3.eq.rack) then
         call gtfld(ibuf,isave,ich-2,ic1,ic2)
         il=ic2-ic1+1
         call fs_get_rack_type(rack_type)
         if(rack_type.eq.K41.or.rack_type.eq.K41U) then
            if (ichcm_ch(ibuf,ic1,'1-4').eq.0.and.il.eq.3) then
               ifp(1)=ichnl
            else if (ichcm_ch(ibuf,ic1,'5-8').eq.0.and.il.eq.3) then
               ifp(5)=ichnl
            else if (ichcm_ch(ibuf,ic1,'9-12').eq.0.and.il.eq.4) then
               ifp(9)=ichnl
            else if (ichcm_ch(ibuf,ic1,'13-16').eq.0.and.il.eq.5) then
               ifp(13)=ichnl
            else
               ip(3) = -204
               if (ip(3).lt.0) return
            endif
         else
            ipos=-1
            if (ichcm_ch(ibuf,ic1,'a').eq.0.and.il.eq.2) then
               ipos=0
            else if (ichcm_ch(ibuf,ic1,'b').eq.0.and.il.eq.2) then
               ipos=8
            endif
            ivc = ias2b(ibuf,ic1+1,1)
            if(ipos.ne.-1.and.ivc.gt.0.and.ivc.lt.9) then
               ifp(ipos+ivc)=ichnl
            else
               ip(3) = -205
               if (ip(3).lt.0) return
            endif
         endif
      endif
      ifc = ifc+1 
      goto 300
C
      end 
