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
      subroutine tplisd_pfb(ip,itpis_dbbc_pfb)
C  parse tpi list c#870115:04:30# 
C
C 1.1.   TPLISV parses the list of possible TPI detectors for
C        a DBBC rack in PFB configuration.
C 
C     INPUT VARIABLES:
C 
      dimension ip(1) 
C               - parameters from SLOWP 
C        IP(1)  - class number of input parameter buffer
C        IP(2-5)- not used
C 
C     OUTPUT VARIABLES: 
C 
      integer itpis_dbbc_pfb(1)
C      - TPIs requested, 0=not wanted, 1=get it 
C        IP(3) - ERROR RETURN 
C        IP(4) - who we are 
C 
C     CALLED SUBROUTINES: FDFLD,JCHAR
C
C
C 2.2.   COMMON BLOCKS USED 
      include '../include/fscom.i'
C 
C 3.  LOCAL VARIABLES 
C 
C        ICH    - character counter 
C     NCHAR  - character count
      parameter (ibufln=40)
      integer*2 ibuf(ibufln), iprm(4)
C               - class buffer, holding command 
C        ILEN   - length of IBUF, chars 
      dimension ireg(2) 
      integer get_buf, ichcm_ch
C               - registers from EXEC calls 
      character cjchar
C
      integer itpis_test_pfb(MAX_DBBC_PFB_DET)
C 
      equivalence (reg,ireg(1))
C 
C 4.  CONSTANTS USED
C 
C 5.  INITIALIZED VARIABLES 
C 
      data ilen/80/ 
C 
C 6.  PROGRAMMER: NRV 
C     LAST MODIFIED:  840308  MWH  added call to MDNAM for module mnemonic
C 
C     PROGRAM STRUCTURE 
C 
C     1. If class buffer contains command name with "=" then we have
C     parameters to get the TPIs.  If only the command name is present, 
C     then use the default. 
C 
      ierr = 0
      iclcm = ip(1) 
      if (iclcm.eq.0) then
        ierr = -1
        goto 990
      endif
      call ifill_ch(ibuf,1,ibufln*2,' ')
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) ieq = nchar + 1 
C                   Set counter to end of command for default 
C 
C 
C     2. Step through buffer getting each parameter and decoding it.
C     Command from user looks like: 
C                   TPI=<list>
C     where <list> may contain the following key words: 
C                   <null> - no default
C                   ALL - all possible devices 
C                   FORMBBC - formatter VC's being recorded
C                   FORMIF - IFs of formatter VC's being recorded
C                   ALL - PFB BBCs plus IFA IFB IFC IFD
C                   BBCU - PFB BBCs that are USB, except 0s, **NYI**
C                   BBCL - PFB BBCs that are LSB **NYI**
C                   EVENU - even-numbered PFB BBCs USB, except 0s, **NYI**
C                   EVENL - even-numbered PFB BBCs LSB **NYI**
C                   ODDU - odd-numbered PFB BBCs USB, except 0s, **NYI**
C                   ODDL - odd-numbered PFB BBCs LSB **NYI**
C                   IFn - IF a, b, c, or d 
C                   in, i=a,b,c,d, n=0-63 (0-15 on first core on IF
C 
      do i=1,MAX_DBBC_PFB_DET
        itpis_dbbc_pfb(i) = 0
        itpis_test_pfb(i) = 0
      enddo
C                   Turn off all of the TPIs to start 
      ich = 1+ieq 
      do 290 i=1,MAX_DBBC_PFB_DET
        call fdfld(ibuf,ich,nchar,ic1,ic2)
        if(ic1.eq.0) go to 280
c
        inumb=ic2-ic1+1
        inumb=min(inumb,8)
        idum = ichmv(iprm,1,ibuf,ic1,inumb)
        ich=ic2+2 !! point beyond next comma
C                   Pick up each parameter as characters
        if (cjchar(iprm,1).eq.'*') goto 281
C                           * 
C                   We haven't any stored values to pick up here
C 
        if (ichcm_ch(iprm,1,'formbbc').ne.0) goto 205
        call fs_get_rack(rack)
        call fs_get_rack_type(rack_type)
        call fs_get_drive(drive)
        call fs_get_drive_type(drive_type)
        if(rack.eq.DBBC.and.
     &       (DBBC_PFB.eq.rack_type.or.DBBC_PFB_FILA10G.eq.rack_type)
     &       .and.
     &       drive(1).eq.mk5.and.
     &       (drive_type(1).eq.mk5b.or.drive_type(1).eq.mk5b_bs .or.
     &       drive_type(1).eq.mk5c.or.drive_type(1).eq.mk5c_bs .or.
     &       drive_type(1).eq.FLEXBUFF)
     &       ) then
           call fc_mk5dbbcd_pfb(itpis_dbbc_pfb)
        endif
        goto 289
c
205     continue
        if (ichcm_ch(iprm,1,'formif').ne.0) goto 210
        call fs_get_rack(rack)
        call fs_get_rack_type(rack_type)
        call fs_get_drive(drive)
        call fs_get_drive_type(drive_type)
        if(rack.eq.DBBC.and.
     &       (DBBC_PFB.eq.rack_type.or.DBBC_PFB_FILA10G.eq.rack_type)
     &       .and.
     &       drive(1).eq.mk5.and.
     &       (drive_type(1).eq.mk5b.or.drive_type(1).eq.mk5b_bs .or.
     &       drive_type(1).eq.mk5c.or.drive_type(1).eq.mk5c_bs .or.
     &       drive_type(1).eq.FLEXBUFF)
     &       ) then
           call fc_mk5dbbcd_pfb(itpis_test_pfb)
        endif
        call fs_get_dbbc_cond_mods(dbbc_cond_mods)
        call fs_get_dbbc_como_cores(dbbc_como_cores)
        icore=0
        do j=1,dbbc_cond_mods
           do jj=1,dbbc_como_cores(j)
              icore=icore+1
              do ii=1,16
                 if(itpis_test_pfb(ii+(icore-1)*16).ne.0) then
                    itpis_dbbc_pfb(MAX_DBBC_PFB+j)=1
                 endif
              enddo
           enddo
        enddo
        goto 289
c
 210    continue
        if (ichcm_ch(iprm,1,'all').ne.0) goto 220
        call fs_get_dbbc_cores(dbbc_cores)
        do ii=1,dbbc_cores
           do jj=2,16
              itpis_dbbc_pfb((ii-1)*16+jj) = 1
           enddo
        enddo
        call fs_get_dbbc_cond_mods(dbbc_cond_mods)
        do ii=1,dbbc_cond_mods
           itpis_dbbc_pfb(ii+MAX_DBBC_PFB) = 1
        enddo
        goto 289
 
220     if (ichcm_ch(iprm,1,'evenu').ne.0) goto 225
c        do ii=MAX_DBBC_BBC+2,MAX_DBBC_BBC+MAX_DBBC_BBC,2
c          itpis_dbbc(ii) = 1
c        enddo
        goto 289
C
225     if (ichcm_ch(iprm,1,'evenl').ne.0) goto 230
c        do ii=2,MAX_DBBC_BBC,2
c          itpis_dbbc(ii) = 1
c        enddo
        goto 289
C 
230     if (ichcm_ch(iprm,1,'oddu').ne.0) goto 235
c        do ii=MAX_DBBC_BBC+1,MAX_DBBC_BBC+MAX_DBBC_BBC,2
c          itpis_dbbc(ii) = 1
c        enddo
        goto 289
C
235     if (ichcm_ch(iprm,1,'oddl').ne.0) goto 240
c        do ii=1,MAX_DBBC_BBC,2
c          itpis_dbbc(ii) = 1
c        enddo
        goto 289
C 
240     continue 
        call fs_get_dbbc_como_cores(dbbc_como_cores)
        call fs_get_dbbc_cond_mods(dbbc_cond_mods)
        ii=index('abcd',cjchar(iprm,1))
        if(ii.ge.1.and.ii.le.dbbc_cond_mods) then
           ichan=ias2b(iprm,2,2)
           if(ichan.ne.-32768.and.inumb.eq.3.and.
     &          ichan.ge.1.and.ichan.lt.dbbc_como_cores(ii)*16) then
              do jj=2,ii
                 ichan=ichan+16*dbbc_como_cores(jj-1)
              enddo
              itpis_dbbc_pfb(1+ichan) = 1
           else
              goto 285
           endif
        else if(ichcm_ch(iprm,1,'if').eq.0.and.inumb.eq.3) then
           ii=index('abcd',cjchar(iprm,3))
           if(ii.ge.1.and.ii.le.dbbc_cond_mods) then
              itpis_dbbc_pfb(MAX_DBBC_PFB+ii) = 1
           else
              goto 285
           endif
        else if(ichcm_ch(iprm,1,'i').eq.0.and.inumb.eq.2) then
           ii=index('abcd',cjchar(iprm,2))
           if(ii.ge.1.and.ii.le.dbbc_cond_mods) then
              itpis_dbbc_pfb(MAX_DBBC_PFB+ii) = 1
           else
              goto 285
           endif
        else
           goto 285
        endif
        goto 289
C 
280     ierr = -101
        goto 990
281     ierr = -102
        goto 990
285     ierr = -206
        goto 990
C 
289     continue
        if(ich.gt.nchar) go to 291
290     continue
 291    continue
        do i=1,MAX_DBBC_PFB_DET
           if(itpis_dbbc_pfb(i).ne.0) goto 990
        enddo
c
c nothing selected
c
        ierr = -204
        goto 990
C 
C 
C     3. We are finished with our job.
C 
990   ip(3) = ierr
      call char2hol('qk',ip(4),1,2)
      return
      end 
