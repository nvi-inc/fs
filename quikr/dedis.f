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
      subroutine dedis(ip,iclcm)
C  decoder display c#870115:04:38#
C
C 1.1.   DEDIS gets data from the decoder.
C
C     INPUT VARIABLES:
C
      dimension ip(1)
C        IP(1)  - class number of buffer from MATCN
C        IP(2)  - number of records in class
C        IP(3)  - error return from MATCN
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
C 2.5.   SUBROUTINE INTERFACE:
C
C     CALLED SUBROUTINES: character utilities
C
C 3.  LOCAL VARIABLES
C
      integer*2 ibuf(5,5),ibuf2(30)
      integer*2 ias(10)
C               - input class buffers, output display buffer
C        ILEN   - length of buffers, chars
C        NCH    - character counter
C        I      - bit, converted to 0 or 1
C        IA     - hex char from MAT
      dimension nr(6),nc(6)
C                 - mode names, number of records, number of characters
      dimension ierrcn(3)
      logical kcom,kdata,kcrc,kbit
C              - true if COMMON variables wanted
C
      dimension ireg(2)
      integer*2 lmode(12),ierrc(3,3),lchan
      integer*2 mask,istate
      integer get_buf
C               - registers from EXEC
      equivalence (reg,ireg(1))
C
C 4.  CONSTANTS USED
C
C 5.  INITIALIZED VARIABLES
C
      data ilen/10/
      data nr/2,1,2,3,1,5/
      data nc/3,3,4,4,3,3/
      data lmode  /2hau,2hx ,2hsy,2hn ,2hti,2hme,2hda,2hta,2her,2hr ,
     &             2hcr,2hc /
      data ierrc  /2hby,2hte,2h  ,2hfr,2ham,2he ,2hre,2hse,2ht /
      data ierrcn /4,5,6/
      data lchan/2hab/
      data mask/o'7003'/
C
C 6.  PROGRAMMER: NRV
C     LAST MODIFIED: CREATED 790319
C# LAST COMPC'ED  870115:04:38 #
C
C     PROGRAM STRUCTURE
C
C     1. First check error return from MATCN.  If not 0, get out
C     immediately.  If setup data wanted ( ? ), skip class read.
C 
      kcom = (ichcm_ch(ip(4),1,'?').eq.0)
C 
      iclass = ip(1)
      ncrec = ip(2) 
      ierr = ip(3)
      nrec = 0
C 
      if (kcom) goto 200
      if (ierr.lt.0) goto 990 
      if (iclass.eq.0.or.iclcm.eq.0) goto 990 
C 
C 
C     2. Get class buffer with command in it.  Set up first part
C     of output buffer.  Get first buffer from MATCN. 
C 
200   ireg(2) = get_buf(iclcm,ibuf2,-ilen,idum,idum)
C 
      nchar = ireg(2) 
      nch = iscn_ch(ibuf2,1,nchar,'=')
      kdata = nch.eq.0
C                   If our command was only "device" we are waiting for 
C                   data and know what to expect. 
      if (nch.eq.0) nch = nchar+1 
C                   If no "=" found, position after last character
      nch = ichmv_ch(ibuf2,nch,'/') 
C                   Put / to indicate a response
C 
      if (kcom) goto 310
      if (kdata) goto 230 
C 
      do 220 i=1,ncrec
        if (i.ne.1) nch=mcoma(ibuf2,nch)
C                   If not first parm, put comma before 
        ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
        nchar = ireg(2) 
C       NCH = ICHMV(IBUF2,NCH,IBUF(2),1,NCHAR-2)
        nch = ichmv(ibuf2(1),nch,ibuf(2,1),1,nchar-2)
C                   Move buffer contents into output list 
220     continue
      goto 500
C 
230   do 240 i=1,nr(imoddc) 
        ireg(2) = get_buf(iclass,ibuf(1,i),-ilen,idum,idum) 
        ireg(2) = get_buf(iclass,ibuf(1,i),-ilen,idum,idum) 
C                   Now we have disposed of the ACK buffers 
        ireg(2) = get_buf(iclass,ibuf(1,i),-ilen,idum,idum) 
240     continue
        if (ncrec.gt.3*nr(imoddc)) call clrcl(iclass) 
C 
C 
C     3. Now the buffer contains: DECODE=<chan>,<mode>, and we want to add
C     the data. 
C     Format of data received from decoder: 
C
C     DEdddddddd
C     where each "d" is a character with data.  We only report the
C     characters directly.
C
310   nch = ichmv(ibuf2,nch,lchan,ichand+1,1)
      nch = mcoma(ibuf2,nch)
      nch = ichmv(ibuf2,nch,lmode,imoddc*4-3,nc(imoddc))
      if (kcom) then
         nch=mcoma(ibuf2,nch)
         nch=ichmv(ibuf2,nch,ierrc(1,ierrdc_fs),1,ierrcn(ierrdc_fs))
         goto 500
      endif
C
      if(imoddc.ne.6) then
        do i=1,nr(imoddc)
          nch = mcoma(ibuf2,nch)
          nch = ichmv(ibuf2,nch,ibuf(1,i),3,8)
        enddo
      else
        in=1
        do i=1,5
          do j=2,5
            call pchar(ias,in,ia22h(ibuf(j,i)))
            in=in+1
          enddo
        enddo
        istate=0
        in=1
        call crcc(12,mask,istate,ias,in,148,ias,0)
        nch=mcoma(ibuf2,nch)
        kcrc=.true.
        istatei=istate
        do i=1,12
          kcrc=kcrc.and.(
     .         (igetb(ias(10),4+i).eq.1)
     .              .eqv.
     .         kbit(istatei,i)
     .                )
        enddo
        if(kcrc) then
          nch=ichmv_ch(ibuf2,nch,'pass')
        else
          nch=ichmv_ch(ibuf2,nch,'fail')
            call logit7ci(0,0,0,0,-301,'qd',0)
        endif
      endif
C
C     5. Now send the buffer to SAM.
C
500   iclass = 0
      nch = nch - 1
      call put_buf(iclass,ibuf2,-nch,'fs','  ')
C                   Send buffer starting with TP to display
C
      ip(1) = iclass
      ip(2) = 1
      ip(3) = 0
      call char2hol('qd',ip(4),1,2)
990   return
      end
