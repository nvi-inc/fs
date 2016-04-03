      subroutine tplisd(ip,itpis_dbbc)
C  parse tpi list c#870115:04:30# 
C
C 1.1.   TPLISV parses the list of possible TPI detectors for
C        a DBBC rack.
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
      integer itpis_dbbc(1)
C      - TPIs requested, 0=not wanted, 1=get it 
C        IP(3) - ERROR RETURN 
C        IP(4) - who we are 
C 
C     CALLED SUBROUTINES: FDFLD,JCHAR,DTNAM 
C
C
C 2.2.   COMMON BLOCKS USED 
      include '../include/fscom.i'
C 
C 3.  LOCAL VARIABLES 
C 
C        ICH    - character counter 
C     NCHAR  - character count
C     LPRM   - 2-character mnemonic for detector name 
      parameter (ibufln=40)
      integer*2 ibuf(ibufln), iprm(4), dtnam, lprm
C               - class buffer, holding command 
C        ILEN   - length of IBUF, chars 
      dimension ireg(2) 
      integer get_buf, ichcm_ch
C               - registers from EXEC calls 
      character cjchar
C
      integer itpis_test(MAX_DBBC_DET)
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
C                   ALL - the default gets BBC plus IFA IFB IFC IFD
C                   BBCU - gets B1 to 16 USB
C                   BBCL - gets B1 to 16 LSB
C                   EVENU - even-numbered BBCs USB
C                   EVENL - even-numbered BBCs LSB
C                   ODDU - odd-numbered BBCs USB
C                   ODDL - odd-numbered BBCs LSB
C                   IFn - IF a, b, c, or d 
C                   nu or nl, n=1,...,16
C 
      do i=1,MAX_DBBC_DET
        itpis_dbbc(i) = 0
        itpis_test(i) = 0
      enddo
C                   Turn off all of the TPIs to start 
      ich = 1+ieq 
      do 290 i=1,MAX_DBBC_DET
        call fdfld(ibuf,ich,nchar,ic1,ic2)
        if(ic1.eq.0) go to 280
c
        inumb=ic2-ic1+1
        inumb=min(inumb,8)
        idum = ichmv(iprm,1,ibuf,ic1,inumb)
        ich=ic2+2 !! point beyond next comma
C                   Pick up each parameter as characters
        lprm=dtnam(iprm,1,inumb)
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
     &       (DBBC_DDC.eq.rack_type.or.DBBC_DDC_FILA10G.eq.rack_type)
     &       .and.
     &       drive(1).eq.mk5.and.
     &       (drive_type(1).eq.mk5b.or.drive_type(1).eq.mk5b_bs .or.
     &       drive_type(1).eq.mk5c.or.drive_type(1).eq.mk5c_bs .or.
     &       drive_type(1).eq.FLEXBUFF)
     &       ) then
           call fc_mk5dbbcd(itpis_dbbc)
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
     &       (DBBC_DDC.eq.rack_type.or.DBBC_DDC_FILA10G.eq.rack_type)
     &       .and.
     &       drive(1).eq.mk5.and.
     &       (drive_type(1).eq.mk5b.or.drive_type(1).eq.mk5b_bs .or.
     &       drive_type(1).eq.mk5c.or.drive_type(1).eq.mk5c_bs .or.
     &       drive_type(1).eq.FLEXBUFF)
     &       ) then
           call fc_mk5dbbcd(itpis_test)
        endif
        call fs_get_dbbc_cond_mods(dbbc_cond_mods)
        do j=0,dbbc_cond_mods-1
           do ii=1,MAX_DBBC_BBC
              if(itpis_test(ii).ne.0.or.
     &             itpis_test(ii+MAX_DBBC_BBC).ne.0) then
                 call fs_get_dbbc_source(isrce,ii)
                 if(isrce.eq.j) then
                    itpis_dbbc(MAX_DBBC_BBC*2+1+j)=1
                 endif
              endif
           enddo
        enddo
        goto 289
c
 210    continue
        if (ichcm_ch(iprm,1,'all').ne.0) goto 220
        call fs_get_dbbc_cores(dbbc_cores)
        do ii=1,dbbc_cores*4
           itpis_dbbc(ii) = 1
           itpis_dbbc(ii+MAX_DBBC_BBC) = 1
        enddo
        call fs_get_dbbc_cond_mods(dbbc_cond_mods)
        do ii=1,dbbc_cond_mods
           itpis_dbbc(ii+2*MAX_DBBC_BBC) = 1
        enddo
        goto 289
 
220     if (ichcm_ch(iprm,1,'evenu').ne.0) goto 225
        do ii=MAX_DBBC_BBC+2,MAX_DBBC_BBC+MAX_DBBC_BBC,2
          itpis_dbbc(ii) = 1
        enddo
        goto 289
C
225     if (ichcm_ch(iprm,1,'evenl').ne.0) goto 230
        do ii=2,MAX_DBBC_BBC,2
          itpis_dbbc(ii) = 1
        enddo
        goto 289
C 
230     if (ichcm_ch(iprm,1,'oddu').ne.0) goto 235
        do ii=MAX_DBBC_BBC+1,MAX_DBBC_BBC+MAX_DBBC_BBC,2
          itpis_dbbc(ii) = 1
        enddo
        goto 289
C
235     if (ichcm_ch(iprm,1,'oddl').ne.0) goto 240
        do ii=1,MAX_DBBC_BBC,2
          itpis_dbbc(ii) = 1
        enddo
        goto 289
C 
240     continue 
        if (lprm.eq.0) goto 285
        ii=index('123456789abcdefg',cjchar(lprm,1))
        if(ii.ge.1.and.ii.le.MAX_DBBC_BBC) then
           if (cjchar(lprm,2).eq.'u') then
              itpis_dbbc(MAX_DBBC_BBC+ii) = 1
           else if (cjchar(lprm,2).eq.'l') then
              itpis_dbbc(ii) = 1
           else
              goto 285
           endif
           goto 289
        endif
C 
250     if (ichcm_ch(lprm,1,'i').ne.0) goto 285
          if (ichcm_ch(lprm,2,'a').eq.0) then
            itpis_dbbc(MAX_DBBC_BBC*2+1) = 1
          else if (ichcm_ch(lprm,2,'b').eq.0) then
            itpis_dbbc(MAX_DBBC_BBC*2+2) = 1
          else if (ichcm_ch(lprm,2,'c').eq.0) then
            itpis_dbbc(MAX_DBBC_BBC*2+3) = 1
          else if (ichcm_ch(lprm,2,'d').eq.0) then
            itpis_dbbc(MAX_DBBC_BBC*2+4) = 1
          else
            goto 285
          endif
        goto 289
C 
280     ierr = -101
        goto 990
281     ierr = -102
        goto 990
285     ierr = -202
        goto 990
C 
289     continue
        if(ich.gt.nchar) go to 291
290     continue
 291    continue
        do i=1,MAX_DBBC_DET
           if(itpis_dbbc(i).ne.0) goto 990
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
