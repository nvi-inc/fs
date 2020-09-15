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
      subroutine dbbc3_equip(idcb,name,ip)
      implicit none
      integer idcb(2)
      character*(*) name
      integer*4 ip(5)
c
      integer ias2b
c
      integer ierr,idum,ilen,ich,il,ic1,ic2,i,ifc,ind,idbbcv,idbbcvc
      integer*2 ibuf(50)
      character*4 decoder,pcalc
      character*18 dbbcv
      double precision das2b
      character*7 m5bcrate
      logical kmove
      integer*2 line1(16),line2(2),line3(13)
c
      include '../include/fscom.i'
c                 1    2    3    4    5    6    7    8    9   10
c      data line1/29,2hdb,2hbc,2h3.,2hct,2hl ,2hli,2hne,2h t,2hha,
c     &         2ht ,2hfa,2hil,2hed,2h: ,2h' /
c      data line2/ 1,2h' /
c      data line3/24,2hdb,2hbc,2h3.,2hct,2hl ,2hat,2h e,2hnd,2h o,
c     &         2hf ,2hfi,2hle /

      call char2hol("dbbc3.ctl line that failed: '",line1(2),1,30)
      line1(1)=29
      call char2hol("' ",line2(2),1,2)
      line2(1)=1
      call char2hol("dbbc3.ctl at end of file",line3(2),1,24)
      line3(1)=24

      call fmpopen(idcb,name,ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7ci(0,0,0,1,-139,'bo',ierr)
        goto 995
      endif
c
c bbcs/if anf ifs
c
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-185,'bo',1)
        goto 990
      endif
      call lower(ibuf,ilen)
c
      ifc=1
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-186,'bo',1)
        goto 990
      endif
c
      dbbc3_ddc_bbcs_per_if = ias2b(ibuf,ic1,ic2-ic1+1)
      if (dbbc3_ddc_bbcs_per_if.ne.8.and.
     &     dbbc3_ddc_bbcs_per_if.ne.12.and.
     &     dbbc3_ddc_bbcs_per_if.ne.16) then
         call logit7ci(0,0,0,1,-186,'bo',1)
         goto 990
      endif
c
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-186,'bo',1)
        goto 990
      endif
c
      dbbc3_ddc_ifs = ias2b(ibuf,ic1,ic2-ic1+1)
      if ( dbbc3_ddc_ifs.lt.1.or.
     &     dbbc3_ddc_ifs.gt.8) then
         call logit7ci(0,0,0,1,-186,'bo',1)
         goto 990
      endif
c 
      call fs_set_dbbc3_ddc_bbcs_per_if(dbbc3_ddc_bbcs_per_if)
      call fs_set_dbbc3_ddc_ifs(dbbc3_ddc_ifs)
c
c DBBC3 DDCU firmware version
c
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-185,'bo',2)
        goto 990
      endif
      call lower(ibuf,ilen)
      ifc=1
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-186,'bo',2)
        goto 990
      endif
C
      call hol2char(ibuf,ic1,ic2,dbbcv)
      kmove=dbbcv(1:1).eq.'v'
      do i=1,17
         if(kmove) then
            dbbcv(i:i)=dbbcv(i+1:i+1)
         endif
         if(dbbcv(i:i).ne.' ') idbbcvc=i
      enddo
      if(idbbcvc.gt.16) then
         call logit7ci(0,0,0,1,-186,'bo',2)
         goto 990
      endif
      idbbcv=0
      do i=1,3
        ind=index('01234567890',dbbcv(i:i))
        if(ind.eq.0) then
           call logit7ci(0,0,0,1,-186,'bo',2)
           goto 990
        endif
        idbbcv=idbbcv*10+(ind-1)
      enddo
      if(idbbcv.lt.121) then
         call logit7ci(0,0,0,1,-186,'bo',2)
         goto 990
      endif
c
      dbbc3_ddcu_v =idbbcv
      dbbc3_ddcu_vs= dbbcv
      dbbc3_ddcu_vc=idbbcvc
      call fs_set_dbbc3_ddcu_v(dbbc3_ddcu_v)
      call fs_set_dbbc3_ddcu_vs(dbbc3_ddcu_vs)
      call fs_set_dbbc3_ddcu_vc(dbbc3_ddcu_vc)
c
c DBBC3 DDCV firmware version
c
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-185,'bo',3)
        goto 990
      endif
      call lower(ibuf,ilen)
      ifc=1
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-186,'bo',3)
        goto 990
      endif
C
      call hol2char(ibuf,ic1,ic2,dbbcv)
      kmove=dbbcv(1:1).eq.'v'
      do i=1,17
         if(kmove) then
            dbbcv(i:i)=dbbcv(i+1:i+1)
         endif
         if(dbbcv(i:i).ne.' ') idbbcvc=i
      enddo
      if(idbbcvc.gt.16) then
         call logit7ci(0,0,0,1,-186,'bo',3)
         goto 990
      endif
      idbbcv=0
      do i=1,3
        ind=index('01234567890',dbbcv(i:i))
        if(ind.eq.0) then
           call logit7ci(0,0,0,1,-186,'bo',3)
           goto 990
        endif
        idbbcv=idbbcv*10+(ind-1)
      enddo
      if(idbbcv.lt.121) then
         call logit7ci(0,0,0,1,-186,'bo',3)
         goto 990
      endif
c
      dbbc3_ddcv_v =idbbcv
      dbbc3_ddcv_vs= dbbcv
      dbbc3_ddcv_vc=idbbcvc
      call fs_set_dbbc3_ddcv_v(dbbc3_ddcv_v)
      call fs_set_dbbc3_ddcv_vs(dbbc3_ddcv_vs)
      call fs_set_dbbc3_ddcv_vc(dbbc3_ddcv_vc)
c
      return
c
 990  continue
      if(ierr.eq.0.and.ilen.eq.-1) then
        call put_cons(line3(2),line3(1))
      else
        call put_cons_raw(line1(2),line1(1))
        call put_cons_raw(ibuf,ilen)
        call put_cons(line2(2),line2(1))
      endif
 991  continue
      call fmpclose(idcb,ierr)
  995  continue
      ip(3) = -1
       return
      end
