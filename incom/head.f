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
      subroutine head(idcb,name,ip,ierr_num,indxtp)
      integer idcb(2),indxtp,ierr_num
      character*(*) name
      integer*4 ip(5)
c
      integer ierr,idum,ilen,ich,ic1,ic2,line
      integer*2 ibuf(50)
      double precision das2b
c
      include '../include/fscom.i'
c
      call fmpopen(idcb,name,ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7ci(0,0,0,1,ierr_num,'bo',ierr)
        goto 995
      endif
c
      line=1
      call readg(idcb,ierr,ibuf,ilen)
      if(ierr.lt.0) goto 990
      call lower(ibuf,ilen)
      ich=1
      do i=1,4
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if(ic1.eq.0) goto 990
        idum=-1
        if(ichcm_ch(ibuf,ic1,'all').eq.0) idum=0
        if(ichcm_ch(ibuf,ic1,'odd').eq.0) idum=1
        if(ichcm_ch(ibuf,ic1,'even').eq.0) idum=2
        if(idum.lt.0.or.(idum.eq.0.and.i.eq.4)) goto 990
        if(i.eq.1) wrhd_fs(indxtp)=idum
        if(i.eq.2) rdhd_fs(indxtp)=idum
        if(i.eq.3) rpro_fs(indxtp)=idum
        if(i.eq.4) rpdt_fs(indxtp)=idum
      enddo
      call fs_set_rdhd_fs(rdhd_fs,indxtp)
      call fs_set_wrhd_fs(wrhd_fs,indxtp)
C
C INCHWORM PARAMETERS
C
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if(ierr.lt.0) goto 990
      call lower(ibuf,ilen)
      ich=1
c
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if(ic1.eq.0) goto 990
      if(ichcm_ch(ibuf,ic1,'adaptive').eq.0) then
         kadapt_fs(indxtp)=.true.
      else if(ichcm_ch(ibuf,ic1,'fixed').eq.0) then
         kadapt_fs(indxtp)=.false.
      else
         goto 990
      endif
c
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if(ic1.eq.0) goto 990
      if(ichcm_ch(ibuf,ic1,'yes').eq.0) then
         kiwslw_fs(indxtp)=.true.
      else if(ichcm_ch(ibuf,ic1,'no').eq.0) then
         kiwslw_fs(indxtp)=.false.
      else
         goto 990
      endif
c
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      lvbosc_fs(indxtp) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if(ierr.ne.0) goto 990
c
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      ilvtl_fs(indxtp) = ias2b(ibuf,ic1,ic2-ic1+1)
      if(ilvtl_fs(indxtp).lt.0.or.ilvtl_fs(indxtp).gt.4097) goto 990
C
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich=1
      do i=1,2
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if (ic1.eq.0) goto 990
        fastfw(i,indxtp) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
        if (ierr.ne.0) goto 990
      enddo
C
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich=1
      do i=1,2
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if (ic1.eq.0) goto 990
        slowfw(i,indxtp) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
        if (ierr.ne.0) goto 990
      enddo
c
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich=1
      do i=1,2
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if (ic1.eq.0) goto 990
        foroff(i,indxtp) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
        if (ierr.ne.0) goto 990
      enddo
c
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich=1
      do i=1,2
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if (ic1.eq.0) goto 990
        fastrv(i,indxtp) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
        if (ierr.ne.0) goto 990
      enddo
c
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich=1
      do i=1,2
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if (ic1.eq.0) goto 990
        slowrv(i,indxtp) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
        if (ierr.ne.0) goto 990
      enddo
c
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich=1
      do i=1,2
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if (ic1.eq.0) goto 990
        revoff(i,indxtp) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
        if (ierr.ne.0) goto 990
      enddo
c
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich=1
      do i=1,2
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if (ic1.eq.0) goto 990
        pslope(i,indxtp) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
        if (ierr.ne.0) goto 990
      enddo
c
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich=1
      do i=1,2
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if (ic1.eq.0) goto 990
        rslope(i,indxtp) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
        if (ierr.ne.0) goto 990
      enddo
c
      call fmpclose(idcb,ierr)
      return

 990  continue
      call logit7ci(0,0,0,1,ierr_num-1,'bo',line)
 995  continue
      ip(3)=-1
      return
      end
