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
      subroutine drivev(idcb,name,ip,ierr_num,indxtp)
      integer idcb(2),indxtp,ierr_num
      character*(*) name
      integer*4 ip(5)
c
      integer ierr,idum,ilen,ich,ic1,ic2,line
      integer*2 ibuf(50)
      double precision das2b
      character*8 cpu
c
      include '../include/fscom.i'
c
      call fmpopen(idcb,name,ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7ci(0,0,0,1,ierr_num,'bo',ierr)
        goto 995
      endif
c
      line=0
      call driveall(idcb,ibuf,ip,ierr_num-1,line,indxtp)
      if(ip(3).ne.0) goto 990
C
C  recorder CPU board
C
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      call lower(ibuf,ilen)
      ifc=1
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      if(ic1.le.0) goto 990
      call hol2char(ibuf,ic1,ic2,cpu)
      if(cpu.eq.'mvme162') then
         reccpu(indxtp)=162
      else if(cpu.eq.'mvme117') then
         reccpu(indxtp)=117
      else
         goto 990   
      endif
      call fs_set_reccpu(reccpu,indxtp)
c
c head motion delay field
c
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ifc=1
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      if(ic1.le.0) goto 990
      ihdmndel(indxtp) = ias2b(ibuf,ic1,ic2-ic1+1)
      if (ihdmndel(indxtp).lt.0) goto 990
      call fs_set_ihdmndel(ihdmndel,indxtp)
C
C VACUUM MOTOR VOLTAGE - motorv
C
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      motorv(indxtp) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) goto 990
      call fs_set_motorv(motorv,indxtp)
C
C LINE #11 VACUUM SCALE INTERCEPT - inscint
C
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      inscint(indxtp) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) goto 990
      call fs_set_inscint(inscint,indxtp)
C LINE #12 VACUUM SCALE SLOPE - inscsl
      line=line+1
      call readg(idcb,ierr,ibuf,ilen) 
      if (ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      inscsl(indxtp) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) goto 990
      call fs_set_inscsl(inscsl,indxtp)
C LINE #13 VACUUM SCALE INTERCEPT - outscint
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      outscint(indxtp) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) goto 990
      call fs_set_outscint(outscint,indxtp)
C LINE #14 VACUUM SCALE SLOPE - outscsl 
      line=line+1
      call readg(idcb,ierr,ibuf,ilen) 
      if (ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      outscsl(indxtp) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) goto 990
      call fs_set_outscsl(outscsl,indxtp)
C LINE #15  TAPE THICKNESS - itpthick
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      itpthick(indxtp) = ias2b(ibuf,ic1,ic2-ic1+1)
      if (itpthick(indxtp).lt.0) goto 990
      call fs_set_itpthick(itpthick,indxtp)
C LINE #16 HEAD WRITE VOLTAGE - wrvolt
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      wrvolt(indxtp) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) goto 990
      call fs_set_wrvolt(wrvolt,indxtp)
C LINE #17  CAPSTAN SIZE - capstan
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      capstan(indxtp) = ias2b(ibuf,ic1,ic2-ic1+1)
      if (capstan(indxtp).lt.0) goto 990
      call fs_set_capstan(capstan,indxtp)
C LINE #21 VACUUM MOTOR VOLTAGE THICK TAPE FOR VACUUM SWITHCING - motorv2
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      motorv2(indxtp) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) goto 990
      call fs_set_motorv2(motorv2,indxtp)
C LINE #22  TAPE THICKNESS FOR VACUUM SWITCHING - itpthick2
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      itpthick2(indxtp) = ias2b(ibuf,ic1,ic2-ic1+1)
      if (itpthick2(indxtp).lt.0) goto 990
      call fs_set_itpthick2(itpthick2,indxtp)
C LINE #23 thick tape WRITE VOLTAGE FOR switching - wrvolt2
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      wrvolt2(indxtp) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) goto 990
      call fs_set_wrvolt2(wrvolt2,indxtp)
C LINE #24 HEAD WRITE VOLTAGE FOR VLBA HEAD4 - wrvolt4
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      wrvolt4(indxtp) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) goto 990
      call fs_set_wrvolt4(wrvolt4,indxtp)
C LINE #25 WRITE VOLTAGE FOR VLBA HEAD4 for thick if switching - wrvolt42
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      wrvolt42(indxtp) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) goto 990
      call fs_set_wrvolt42(wrvolt42,indxtp)
      call fmpclose(idcb,ierr)
      return

 990  continue
      call logit7ci(0,0,0,1,ierr_num-1,'bo',line)
 995  continue
      ip(3)=-1
      return
      end
