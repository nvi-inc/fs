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
      subroutine tpput(ip,itpis,isub,ibufr,nch) 
C 
C     TPPUT gets data from the TPIs and puts it into COMMON 
C     Also, formats response with these values. 
C 
C     DATE   WHO CHANGES
C     810913 NRV ADDED FORMATTING OF RESPONSE VALUES
C 
C     INPUT VARIABLES:
C 
      integer*4 ip(5)
C        IP(1)  - class number of buffer from MATCN 
C        IP(2)  - # records in class
C        IP(3)  - error return from MATCN 
      integer itpis(1)
C      - TPI selection
C     ISUB - which sub-function, 3=TPI, 4=TPICAL, 7=TPZERO
C     IBUFR - buffer with first part of response in it
C     NCH - next available character in IBUFR 
C     ILENR - length of IBUFR 
      integer*2 ibufr(1)
C 
C     OUTPUT VARIABLES: 
C 
C        IP(1) -
C        IP(2) -
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
C 
      include '../include/fscom.i'
C 
C 2.5.   SUBROUTINE INTERFACE:
C 
C 3.  LOCAL VARIABLES 
C 
      integer*4 freq
      integer*4 isw(4)
      dimension ld(3) 
C      - dummy for VC conversion
      dimension tret(2)
C      - temporary TP variables 
      parameter (ibufln=15)
      integer*2 ibuf(ibufln),ibufd(ibufln)
C               - input class buffers with MATCN responses
C               - registers from EXEC 
      dimension ireg(2) 
      integer get_buf,ierr
      equivalence (reg,ireg(1)) 
C 
C 4.  CONSTANTS USED
C 
C 5.  INITIALIZED VARIABLES 
C 
      data ibufd/15*2H00/
C 
C 
C     PROGRAM STRUCTURE 
C 
C     1. Step through the TPIs requested which we assume correspond
C     to the responses from MATCN.  Put the TPs into COMMON.
C
      ncrec = ip(2)
      iclass = ip(1)
      nclasr = 0
      iclasr =0
      nr = 0
      do 190 i=1,17
        if (itpis(i).eq.0) goto 190
        if (i.eq.16.and.itpis(15).ne.0) goto 120
C                     This is the case when both IFs were asked for
        if (nr.ge.ncrec) goto 190
        nr = nr + 2
        ireg(2) = get_buf(iclass,ierr, -4,idum,idum)
        ireg(2) = get_buf(iclass,ibuf,-10,idum,idum)
        if (i.gt.14) goto 120
        if(ierr.ge.0) then
           call ma2vc(ibuf,ibuf,ld,id,itp,id,id,id,id,tret,id)
        else
           tret(1)=ierr
        endif
        if (tret(1).ge.65534.5) tret(1)=1.d9
C     If overflow, indicate by $$$$
c       ii = i+(itp-1)*14 
        ii = i+(2-1)*14 
        if (ii.le.0.or.ii.gt.28) goto 190 
        if (isub.eq.3) tpsor(ii) = tret(1)
        if (isub.eq.4) tpspc(ii) = tret(1)
        if (isub.eq.7) tpzero(ii) = tret(1) 
        goto 190
120     continue
        if (i.gt.16) goto 130
        if(ierr.ge.0) then
           call ma2if(ibufd,ibuf,id,id,id,id,tret(1),tret(2),id)
        else
           tret(1)=ierr
           tret(2)=ierr
        endif
        if (i.eq.16) tret(1) = tret(2)
        if (tret(1).ge.65534.5) tret(1)=1.d9
C     For IF2, pick up second value 
        if (isub.eq.3) tpsor(i+14)=tret(1)
        if (isub.eq.4) tpspc(i+14)=tret(1)
        if (isub.eq.7) tpzero(i+14)=tret(1) 
        goto 190
c
130     continue
        if(ierr.ge.0) then
           call ma2i3(ibufd,ibuf,iat,imix,isw(1),isw(2),isw(3),isw(4),
     &          ipcalp,iswp,freq,irem,ipcal,ilo,tret(1))
        else
           tret(1)=ierr
        endif
        if (isub.eq.3) tpsor(i+14)=tret(1)
        if (isub.eq.4) tpspc(i+14)=tret(1)
        if (isub.eq.7) tpzero(i+14)=tret(1) 
190     continue
C
C  format response
C
      nchstart=nch
      call fs_get_ifp2vc(ifp2vc)
      call fs_get_itpivc(itpivc)
      do j=0,3
         do i=1,14
            if (itpis(i).ne.0.and.iabs(ifp2vc(i)).eq.j) then
               if(nch.ge.60) then
                  call put_buf(iclasr,ibufr,2-nch,'fs','  ')
                  nclasr=nclasr+1
                  nch=nchstart
               endif
               nch=ichmv(ibufr,nch,ih22a(i),2,1)
               if(itpivc(i).eq.-1) then
                  nch=ichmv_ch(ibufr,nch,'x')
               elseif(itpivc(i).eq.0) then
                  nch=ichmv_ch(ibufr,nch,'d')
               elseif(itpivc(i).eq.1) then
                  nch=ichmv_ch(ibufr,nch,'l')
               elseif(itpivc(i).eq.2) then
                  nch=ichmv_ch(ibufr,nch,'u')
               else
                  nch=nch+ib2as(and(itpivc(i),7),ibufr,nch,1)
               endif
               nch = mcoma(ibufr,nch)
               if (isub.eq.3) t=tpsor(i+14)
               if (isub.eq.4) t=tpspc(i+14)
               if (isub.eq.7) t=tpzero(i+14)
               nch = nch + ir2as(t,ibufr,nch,6,0)-1
               nch = mcoma(ibufr,nch)
            endif
         enddo
         if(j.gt.0) then
            if(itpis(j+14).ne.0) then
               if(nch.ge.60) then
                  call put_buf(iclasr,ibufr,2-nch,'fs','  ')
                  nclasr=nclasr+1
                  nch=nchstart
               endif
               nch=ichmv_ch(ibufr,nch,'i')
               nch=nch+ib2as(j,ibufr,nch,1)
               nch = mcoma(ibufr,nch)
               if (isub.eq.3) t=tpsor(j+28)
               if (isub.eq.4) t=tpspc(j+28)
               if (isub.eq.7) t=tpzero(j+28)
               nch = nch + ir2as(t,ibufr,nch,6,0)-1
               nch = mcoma(ibufr,nch)
            endif
         endif
         if(nch.gt.nchstart) then
            call put_buf(iclasr,ibufr,2-nch,'fs','  ')
            nclasr=nclasr+1
            nch=nchstart
         endif
      enddo
C                     Put the value into the response 
C

980   ip(1) = iclasr
      ip(2) = nclasr
      ip(3) = 0
      call char2hol('qk',ip(4),1,2)
      ip(5) = 0 
      return
      end 
