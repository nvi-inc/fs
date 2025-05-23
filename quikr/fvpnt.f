*
* Copyright (c) 2020, 2023, 2025 NVI, Inc.
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
      subroutine fvpnt(ip)
C 
C     FVPNT sets up the common variables necessary for
C      the proper execution of program FIVPT
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
C     CALLED SUBROUTINES: FVDIS, utilities
C 
C   LOCAL VARIABLES 
C
      include '../include/boz.i'
      include '../include/dpi.i'
C
C        NCHAR  - number of characters in buffer
C        ICH    - character counter 
      integer*2 ibuf(40)
C               - class buffer
C        ILEN   - length of IBUF, chars 
      integer*2 iprm(20)
C               - parameter returned from FDFLD
      integer*2 dtnam,ldev(2)
      dimension iparm(2)
C               - parameters returned from GTPRM
      dimension ireg(2) 
      integer get_buf,ichcm_ch
C               - registers from EXEC calls
      integer*2 legax(8)
      logical rn_test
      dimension lax(2)
      character cjchar
      integer source,it(6)
      equivalence (reg,ireg(1)),(parm,iparm(1))
C
C  INITIALIZED VARIABLES
C
      data ilen/80/
      data legax/2hha,2hdc,2haz,2hel,2hxy,2hew,2hxy,2hns/
C
C  PROGRAMMER: MWH  CREATED: 840510
C  HISTORY:
C  WHO  WHEN    WHAT 
C  gag  920714  Added Mark IV rack to be valid along with Mark III.
C
C     1. If we have a class buffer, then we are to set the
C     variables in common for FIVPT to use.
C
      call ifill_ch(ibuf,1,ilen,' ') 
      iclcm = ip(1) 
      if (iclcm.ne.0) goto 110
      ierr = -1 
      goto 990
110   ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum) 
      nchar = min0(ilen,ireg(2))
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) goto 390
C                   If no parameters, schedule FIVPT
      if(nchar.eq.ieq) goto 210 
      if (cjchar(ibuf,ieq+1).ne.'?') goto 210
      ip(1) = 0 
      ip(4) = ocp77 
      call fpdis(ip,ibuf,ilen,nchar)
      return
C
C
C     2. Step through buffer getting each parameter and decoding it.
C     2.1 First parm, axis type
C
210   continue
      ich = 1+ieq
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).eq.',') idumm1 = ichmv_ch(lax,1,'hadc')
C                 The default is HADC
      if (cjchar(parm,1).eq.'*') idumm1 = ichmv(lax,1,laxfp,1,4)
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',')
     .  idumm1 = ichmv(lax,1,parm,1,4)
C
      do 215 i=1,13,4
        if(ichcm(lax,1,legax,i,4).eq.0) goto 220
215   continue
      ierr = -201
      goto 990
C 
C     2.2 Second parm, number of repetitions
C 
220   continue
      call gtprm(ibuf,ich,nchar,1,parm,ierr) 
      if (cjchar(parm,1).eq.',') nrep = 1
C                 Default is 1 repetition 
      if (cjchar(parm,1).eq.'*') nrep = nrepfp 
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') 
     .  nrep = iparm(1) 
      if (nrep.ge.-10.and.nrep.le.10.and.nrep.ne.0) goto 230
        ierr = -202 
        goto 990
C 
C     2.3 Third parm, number of points
C 
230   continue
      call gtprm(ibuf,ich,nchar,1,parm,ierr)
      if (cjchar(parm,1).eq.',') npts = 7
C                 Default is 7 points
      if (cjchar(parm,1).eq.'*') npts = nptsfp
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',')npts=iparm(1)
      if(npts.lt.0) then
         npts = 2*(-npts/2)+1
         npts = -npts
      else
         npts = 2*(npts/2)+1
      endif
      if (abs(npts).ge.3.and.abs(npts).le.31) goto 240
        ierr = -203
        goto 990
C
C  2.4  Fourth parm, step size
C
240   continue
      call gtprm(ibuf,ich,nchar,2,parm,ierr)
      if(cjchar(parm,1).ne.',') goto 242
        step = 0.5
        goto 250
242   if(cjchar(parm,1).ne.'*') goto 245
        step = stepfp
        goto 250
245   if(ierr.eq.0) goto 247
        ierr = -204 
        goto 990
247   step = parm 
      ierr = 0
C 
C  2.5  Fifth parm, integration period
C 
250   continue
      call gtprm(ibuf,ich,nchar,1,parm,ierr) 
      if(cjchar(parm,1).eq.',') intp = 1 
      if(cjchar(parm,1).eq.'*') intp = intpfp
      if(cjchar(parm,1).ne.','.and.cjchar(parm,1).ne.'*')
     .   intp = iparm(1)
      if(intp.ge.1.and.intp.le.32) goto 260 
        ierr = -205 
        goto 990
C 
C     2.6 Sixth parm, detector device. (fdfld is right should be gtprm)  
C 
260   continue
      call fdfld(ibuf,ich,nchar,ic1,ic2)
      ich=ich+1
      if (ic1.eq.0) then
        ierr = -106
        goto 990 
      endif
      inumb=min(ic2-ic1+1,4)
      call ifill_ch(iprm,1,40,' ')
      idum = ichmv(iprm,1,ibuf,ic1,inumb)
      call ifill_ch(ldev,1,4,' ')
      if (cjchar(iprm,1).ne.'*'.and.cjchar(iprm,1).ne.',') then
         call fs_get_rack(rack)
         call fs_get_rack_type(rack_type)
         if(0.eq.ichcm_ch(iprm,1,'none')) then
           idum=ichmv_ch(ldev,1,'none')
         else if (DBBC .eq. rack.and.
     &        (DBBC_PFB.eq.rack_type.or.DBBC_PFB_FILA10G.eq.rack_type)
     &        ) then
            idum=ichmv(ldev(1),1,ibuf,ic1,inumb)
        else if(RDBE.ne.rack.and.DBBC3.ne.rack) then
            ldev(1)=dtnam(iprm,1,inumb)
            call char2hol(' ',ldev,3,4)
         else
            idum=ichmv(ldev,1,iprm,1,4)
         endif
         goto 270
      endif
      if (cjchar(iprm,1).eq.'*') then
        idumm1 = ichmv(ldev,1,ldevfp,1,4)
        goto 270
      endif
      if(cjchar(iprm,1).eq.'u'.and.index('56',cjchar(iprm,2)).ne.0) then
        idumm1 = ichmv(ldev,1,iprm,1,2)
        call char2hol(' ',ldev,3,4)
        goto 270
      endif
C
      call char2hol(' ',ldev,3,4)
      call fs_get_rack(rack)
      call fs_get_rack_type(rack_type)
      if (MK3.eq.rack.or.MK4.eq.rack.or.LBA4.eq.rack) then
        if (cjchar(iprm,1).eq.',') idumm1 = ichmv_ch(ldev,1,'i1')
C                      Default for MK3 and MK4 is IF1
        if(cjchar(ldev,1).eq.'i'.or.cjchar(ldev,1).eq.'v') goto 270

      else if (VLBA .eq. rack.or.VLBA4.eq.rack) then
        if (cjchar(iprm,1).eq.',') idumm1 = ichmv_ch(ldev,1,'ia')
C                      Default for VLBA is IA
        if ((cjchar(ldev,1).eq.'i').or.
     *      index('123456789abcde',cjchar(ldev,1)).ne.0)
     *    goto 270
CC  above is MAX_VLBA_BBC
      else if (LBA.eq.rack) then
        if (cjchar(iprm,1).eq.',') idumm1 = ichmv_ch(ldev,1,'p1')
C                      Default for LBA is IFP1
        if(cjchar(ldev,1).eq.'p') goto 270
      else if (DBBC .eq. rack.and.
     &       (DBBC_DDC.eq.rack_type.or.DBBC_DDC_FILA10G.eq.rack_type)
     &       ) then
        if (cjchar(iprm,1).eq.',') idumm1 = ichmv_ch(ldev,1,'ia')
C                      Default for DBBC DDC is IA
CC
        if ((cjchar(ldev,1).eq.'i').or.
     *      index('123456789abcde',cjchar(ldev,1)).ne.0)
     *    goto 270
      else if (DBBC .eq. rack.and.
     &       (DBBC_PFB.eq.rack_type.or.DBBC_PFB_FILA10G.eq.rack_type)
     &       ) then
        if (cjchar(iprm,1).eq.',') idumm1 = ichmv_ch(ldev,1,'ifa')
C                      Default for DBBC DFB is IFA
CC
        if (ichcm_ch(ldev,1,'ia').eq.0) then
           idum=ichmv_ch(ldev,1,'ifa')
        else if (ichcm_ch(ldev,1,'ib').eq.0) then
           idum=ichmv_ch(ldev,1,'ifb')
        else if (ichcm_ch(ldev,1,'ic').eq.0) then
           idum=ichmv_ch(ldev,1,'ifc')
        else if (ichcm_ch(ldev,1,'id').eq.0) then
           idum=ichmv_ch(ldev,1,'ifd')
        endif
        if (cjchar(ldev,1).eq.'i'.or.
     *      index('abcd',cjchar(ldev,1)).ne.0)
     *    goto 270
      else if(RDBE .eq. rack) then
         if (cjchar(iprm,1).eq.',') idumm1 = ichmv_ch(ldev,1,'01a0')
         if(index('abcd',cjchar(ldev,3)).ne.0) goto 270
      else if(DBBC3 .eq. rack) then
         if (cjchar(iprm,1).eq.',') idumm1 = ichmv_ch(ldev,1,'001u')
      endif
C
      ierr = -206
      goto 990
C
C 7th parameter: wait time
C
 270  continue
      call gtprm(ibuf,ich,nchar,1,parm,ierr) 
      if(cjchar(parm,1).eq.',') iwait = 120 
      if(cjchar(parm,1).eq.'*') iwait = IWTFP
      if(cjchar(parm,1).ne.','.and.cjchar(parm,1).ne.'*')
     .   iwait = iparm(1)
      if(iwait.ge.1.and.iwait.le.1200) goto 280
        ierr = -207 
        goto 990
C           Illegal value entered
C
 280  continue
      call gtprm(ibuf,ich,nchar,2,parm,ierr)
      if(0.ne.ichcm_ch(iprm,1,'none').and.
     & cjchar(parm,1).ne.',') then
       ierr=-308
       goto 990
      endif
      if(cjchar(parm,1).ne.',') goto 282
        bm = 0.15*DEG2RAD
        goto 300
282   if(cjchar(parm,1).ne.'*') goto 285
        bm = bmfp_fs
        goto 300
285   if(ierr.eq.0) goto 287
        ierr = -208
        goto 990
287   bm = parm * DEG2RAD
      ierr = 0
C
C  3.0  Set common variables to their new values
C
300   continue
      idumm1 = ichmv(laxfp,1,lax,1,4)
      idumm1 = ichmv(ldevfp,1,ldev,1,4)
      nrepfp = nrep
      nptsfp = npts
      intpfp = intp
      stepfp = step
      iwtfp = iwait
      if(0.eq.ichcm_ch(ldevfp,1,'none')) bmfp_fs=bm
      goto 990
C
C  4.0  Schedule FIVPT to start working
C
390   continue
      do 395 i=1,13,4
        if(ichcm(laxfp,1,legax,i,4).eq.0) goto 400
395   continue
      ierr = -304
      goto 990
C
400   continue

      if(0.eq.ichcm_ch(ldevfp,1,'none')) then
        ichain=0
        goto 410
      endif
      if(cjchar(ldevfp,1).eq.'u') then
         if(cjchar(ldevfp,2).eq.'5') then
            ichain=5
         else
            ichain=6
         endif
         goto 410
      endif
      if(MK3.eq.rack.or.MK4.eq.rack) then
        if(cjchar(ldevfp,1).ne.'i') goto 405
        if(ichcm_ch(ldevfp,1,'i1').ne.0) goto 402
          ichain=1
          goto 410
402     continue
        if(ichcm_ch(ldevfp,1,'i2').ne.0) goto 403
          ichain=2
          goto 410
403     continue
          ichain=3
          goto 410
c
c  video channels
c
405     continue
        indvc = ia2hx(ldevfp,2)
        call fs_get_ifp2vc(ifp2vc)
        ichain=iabs(ifp2vc(indvc))
        if(ichain.lt.1.or.ichain.gt.3) then
          ierr=-216
          goto 990
        endif
      else if(DBBC.eq.rack.and.
     &       (DBBC_DDC.eq.rack_type.or.DBBC_DDC_FILA10G.eq.rack_type)
     &       ) then
        indbc=ia2hx(ldevfp,1)
        if(ichcm_ch(ldevfp,1,'ia').eq.0) then
          ichain=1
        else if(ichcm_ch(ldevfp,1,'ib').eq.0) then
          ichain=2
        else if(ichcm_ch(ldevfp,1,'ic').eq.0) then
          ichain=3
        else if(ichcm_ch(ldevfp,1,'id').eq.0) then
          ichain=4
        else if(indbc.ge.1.and.indbc.le.MAX_DBBC_BBC) then
          call fs_get_dbbc_source(source,indbc)
          ichain=source+1
          if(ichain.lt.1.or.ichain.gt.4) then
            ierr=-217
            goto 990
          endif
        else
          ierr=-213
          goto 990
        endif
      else if(DBBC.eq.rack.and.
     &       (DBBC_PFB.eq.rack_type.or.DBBC_PFB_FILA10G.eq.rack_type)
     &       ) then
         if(ichcm_ch(ldevfp,1,'ifa').eq.0) then
            ichain=1
         else if(ichcm_ch(ldevfp,1,'ifb').eq.0) then
            ichain=2
         else if(ichcm_ch(ldevfp,1,'ifc').eq.0) then
            ichain=3
         else if(ichcm_ch(ldevfp,1,'ifd').eq.0) then
            ichain=4
         else
            call fs_get_dbbc_cond_mods(dbbc_cond_mods)
            call fs_get_dbbc_como_cores(dbbc_como_cores)
            do i=1,dbbc_cond_mods
               if(index('abcd',cjchar(ldevfp,1)).eq.i) then
                  indx=ias2b(ldevfp,2,2)
                  if(indx.ge.1.and.indx.le.16*dbbc_como_cores(i)) then
                     ifchain=i
                  else
                     ierr=-218
                     goto 990
                  endif
               endif
            enddo
            if(ifchain.lt.1.or.ifchain.gt.4) then
               ierr=-218
               goto 990
            endif
         endif
      else if(RDBE.eq.rack) then
         ichan=ias2b(ldevfp,1,2)
         irdbe=index("abcdefghihklm",cjchar(ldevfp,3))
         ifc=index("01234567",cjchar(ldevfp,4))
         if(irdbe.lt.1.or.irdbe.gt.MAX_RDBE .or.
     *        ifc.lt.1.or.ifc.gt.MAX_RDBE_IF.or.
     *        ichan.lt.0.or.ichan.ge.MAX_RDBE_CH) then
            ierr=-220
            goto 990
         endif
      else if(DBBC3.eq.rack) then
         if('i'.eq.cjchar(ldevfp,1,1)) then
            ifc=index('abcdefgh',cjchar(ldevfp,2))
            if(ifc.eq.0.or.0.ne.ichcm_ch(ldevfp,3,'  ')) then
               ierr=-219
               goto 990
            endif
            ichain=ifc
         else
            ibbc=0
            id=0
            do i=1,4
               if(id.lt.11) then
                  id=index('0123456789ul',cjchar(ldevfp,i))
                  if(id.eq.0) then
                     ierr=-219
                     goto 990
                  else if(id.lt.11) then
                     ibbc=ibbc*10+id-1
                  endif
               else if(cjchar(ldevfp,i).ne.' ') then
                  ierr=-219
                  goto 990
               endif
            enddo
            if(ibbc.lt.1.or.ibbc.gt.MAX_DBBC3_BBC) then
               ierr=-219
               goto 990
            endif
            nch=ib2as(ibbc,ldevfp,1,zcp4303)
            if(id.eq.11) then
               call char2hol('u',ldevfp,4,4)
            else
               call char2hol('l',ldevfp,4,4)
            endif
          call fs_get_dbbc3_bbcnn_source(source,ibbc)
          ichain=source+1
          if(ichain.lt.1.or.ichain.gt.MAX_DBBC3_IF) then
            ierr=-217
            goto 990
          endif
         endif
      else    !VLBA
        indbc=ia2hx(ldevfp,1)
        if(ichcm_ch(ldevfp,1,'ia').eq.0) then
          ichain=1
        else if(ichcm_ch(ldevfp,1,'ib').eq.0) then
          ichain=2
        else if(ichcm_ch(ldevfp,1,'ic').eq.0) then
          ichain=3
        else if(ichcm_ch(ldevfp,1,'id').eq.0) then
          ichain=4
CC
        else if(indbc.ge.1.and.indbx.le.14) then
CC  above is MAX_VLBA_BBC
          call fs_get_bbc_source(source,indbc)
          ichain=source+1
          if(ichain.lt.1.or.ichain.gt.4) then
            ierr=-210
            goto 990
          endif
        else
          ierr=-211
          goto 990
        endif
      endif
C
C  Now check the cal and freq values.
410   continue
      if(0.eq.ichcm_ch(ldevfp,1,'none')) then
        calfp = 0.0
        fxfp_fs = 0
        ssizfp = 0
        ichfp_fs = ichain
c    bmfp_fs already set
        goto 504
      endif
c
      call fc_rte_time(it,it(6))
      epoch=it(6)+it(5)/366.
      call fc_get_tcal_fwhm(ldevfp,cal,bm,epoch,fx,corr,ssize,ierr)
      ierr=0
      if(cal.ne.0.0) goto 415
        ierr = -214
        goto 990
415   if(bm.gt.4.8d-8) goto 420
        ierr = -215
        goto 990
420   continue
      calfp = cal
      bmfp_fs= bm
      fxfp_fs = fx
      ssizfp= ssize
      ichfp_fs = ichain
      call fs_get_dbbc_cont_cal_mode(dbbc_cont_cal_mode)
C there is no cont_cal for DBBC IFs
      if(DBBC.eq.rack.and.dbbc_cont_cal_mode.eq.1.and.
     &     calfp.ge.0.and.ichcm_ch(ldevfp,1,'i').eq.0)
     &     calfp=-100
c
      if(rack.eq.MK3.or.rack.eq.MK4) then
        if(cjchar(ldevfp,1).ne.'v') goto 504
        indvc = ia2hx(ldevfp,2)
        call fs_get_freqvc(freqvc)
        if(freqvc(indvc).gt.96.0.and.freqvc(indvc).lt.504.00) goto 504
C             - VC MUST BE SETUP
          ierr = -303
          goto 990
      endif
C          If it's not dormant, then error.
C
504   if(.not.rn_test('fivpt')) goto 510
      ierr = -301
      goto 990
510   continue
      call write_quikr
      call run_prog('fivpt','nowait',ip(1),ip(2),ip(3),ip(4),ip(5))
      ierr=0
C      Schedule FIVPT
990   ip(1) = 0
      ip(2) = 0
      ip(3) = ierr
      call char2hol('qz',ip(4),1,2)
      return
      end
