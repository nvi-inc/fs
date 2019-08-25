      subroutine tplisd3(ip,itpis_dbbc3)
C  parse tpi list c#870115:04:30# 
C
C 1.1.   TPLISV parses the list of possible TPI detectors for
C        a DBBC3 rack.
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
      integer itpis_dbbc3(1)
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
      integer*2 ibuf(ibufln), iprm(4)
C               - class buffer, holding command 
C        ILEN   - length of IBUF, chars 
      dimension ireg(2) 
      integer get_buf, ichcm_ch
C               - registers from EXEC calls 
      character cjchar
C
      integer itpis_test(MAX_DBBC3_DET)
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
      call fs_get_dbbc3_ddc_bbcs_per_if(dbbc3_ddc_bbcs_per_if)
      call fs_get_dbbc3_ddc_ifs(dbbc3_ddc_ifs)
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
C                   EVENU - even-numbered BBCs USB
C                   EVENL - even-numbered BBCs LSB
C                   ODDU - odd-numbered BBCs USB
C                   ODDL - odd-numbered BBCs LSB
C                   IFn - IF a, b, c, d, e, f, g, h 
C                   nu or nl, n=001,...,128
C 
      do i=1,MAX_DBBC3_DET
        itpis_dbbc3(i) = 0
        itpis_test(i) = 0
      enddo
C                   Turn off all of the TPIs to start 
      ich = 1+ieq 
      do 290 i=1,MAX_DBBC3_DET
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
        ierr=-207
        goto 990
c        if(rack.eq.DBBC.and.
c     &       drive(1).eq.mk5.and.
c     &       (drive_type(1).eq.mk5b.or.drive_type(1).eq.mk5b_bs .or.
c     &        drive_type(1).eq.mk5c.or.drive_type(1).eq.mk5c_bs)
c     &       ) then
c           call fc_mk5dbbcd(itpis_dbbc)
c        endif
c        goto 289
c
205     continue
        if (ichcm_ch(iprm,1,'formif').ne.0) goto 210
        call fs_get_rack(rack)
        call fs_get_rack_type(rack_type)
        call fs_get_drive(drive)
        call fs_get_drive_type(drive_type)
        ierr=-207
        goto 990
c        if(rack.eq.DBBC.and.
c     &       drive(1).eq.mk5.and.
c     &       (drive_type(1).eq.mk5b.or.drive_type(1).eq.mk5b_bs .or.
c     &       drive_type(1).eq.mk5c.or.drive_type(1).eq.mk5c_bs)
c     &       ) then
c           call fc_mk5dbbcd(itpis_test)
c        endif
c        do j=0,MAX_DBBC_IF-1
c           do ii=1,MAX_DBBC_BBC
c              if(itpis_test(ii).ne.0.or.
c     &             itpis_test(ii+MAX_DBBC_BBC).ne.0) then
c                 call fs_get_dbbc_source(isrce,ii)
c                 if(isrce.eq.j) then
c                    itpis_dbbc(MAX_DBBC_BBC*2+1+j)=1
c                 endif
c              endif
c           enddo
c        enddo
c        goto 289
c
 210    continue
        if (ichcm_ch(iprm,1,'all').ne.0) goto 220
        do ii=1,dbbc3_ddc_ifs
           itpis_dbbc3(ii+2*MAX_DBBC3_BBC) = 1
           do jj=1,min(dbbc3_ddc_bbcs_per_if,8)
              itpis_dbbc3(jj+(ii-1)*8) = 1
              itpis_dbbc3(jj+(ii-1)*8+MAX_DBBC3_BBC) = 1
           enddo
           if(dbbc3_ddc_bbcs_per_if.gt.8) then
              do jj=9,min(dbbc3_ddc_bbcs_per_if,16)
                 itpis_dbbc3(64+jj-8+(ii-1)*8) = 1
                 itpis_dbbc3(64+jj-8+(ii-1)*8+MAX_DBBC3_BBC) = 1
              enddo
           endif
        enddo
        goto 289
 
220     if (ichcm_ch(iprm,1,'evenu').ne.0) goto 225
        do ii=1,dbbc3_ddc_ifs
           do jj=2,min(dbbc3_ddc_bbcs_per_if,8),2
              itpis_dbbc3(jj+(ii-1)*8+MAX_DBBC3_BBC) = 1
           enddo
           if(dbbc3_ddc_bbcs_per_if.gt.8) then
              do jj=10,min(dbbc3_ddc_bbcs_per_if,16),2
                 itpis_dbbc3(64+jj-8+(ii-1)*8+MAX_DBBC3_BBC) = 1
              enddo
           endif
        enddo
        goto 289
C
225     if (ichcm_ch(iprm,1,'evenl').ne.0) goto 230
        do ii=1,dbbc3_ddc_ifs
           do jj=2,min(dbbc3_ddc_bbcs_per_if,8),2
              itpis_dbbc3(jj+(ii-1)*8) = 1
           enddo
           if(dbbc3_ddc_bbcs_per_if.gt.8) then
              do jj=10,min(dbbc3_ddc_bbcs_per_if,16),2
                 itpis_dbbc3(64+jj-8+(ii-1)*8) = 1
              enddo
           endif
        enddo
        goto 289
C 
230     if (ichcm_ch(iprm,1,'oddu').ne.0) goto 235
        do ii=1,dbbc3_ddc_ifs
           do jj=1,min(dbbc3_ddc_bbcs_per_if,8),2
              itpis_dbbc3(jj+(ii-1)*8+MAX_DBBC3_BBC) = 1
           enddo
           if(dbbc3_ddc_bbcs_per_if.gt.8) then
              do jj=9,min(dbbc3_ddc_bbcs_per_if,16),2
                 itpis_dbbc3(64+jj-8+(ii-1)*8+MAX_DBBC3_BBC) = 1
              enddo
           endif
        enddo
        goto 289
C
235     if (ichcm_ch(iprm,1,'oddl').ne.0) goto 240
        do ii=1,dbbc3_ddc_ifs
           do jj=1,min(dbbc3_ddc_bbcs_per_if,8),2
              itpis_dbbc3(jj+(ii-1)*8) = 1
           enddo
           if(dbbc3_ddc_bbcs_per_if.gt.8) then
              do jj=9,min(dbbc3_ddc_bbcs_per_if,16),2
                 itpis_dbbc3(64+jj-8+(ii-1)*8) = 1
              enddo
           endif
        enddo
        goto 289
C 
240     continue 
        i1=index('0123456789',cjchar(iprm,1))
        if(i1.eq.0) goto 250
        i2=index('0123456789',cjchar(iprm,2))
        if(i2.eq.0) then
           ilast=2
           ii=i1-1
        else
           i3=index('0123456789',cjchar(iprm,3))
           if(i3.eq.0) then
              ilast=3
              ii=(i1-1)*10+i2-1
           else
              ilast=4
              ii=(i1-1)*100+(i2-1)*10+i3-1
           endif
        endif
        if(ii.ge.1.and.ii.le.MAX_DBBC3_BBC) then
           if (cjchar(iprm,ilast).eq.'u') then
              itpis_dbbc3(MAX_DBBC3_BBC+ii) = 1
           else if (cjchar(iprm,ilast).eq.'l') then
              itpis_dbbc3(ii) = 1
           else
              goto 285
           endif
           goto 289
        endif
C 
250     if (ichcm_ch(iprm,1,'i').ne.0) goto 285
        if (ichcm_ch(iprm,3,' ').eq.0) then
	  ipos=2
	else if(ichcm_ch(iprm,2,'f').eq.0) then
	  ipos=3
	else
	  goto 285
	endif
        ii=index('abcdefgh',cjchar(iprm,ipos))
        if(ii.ge.1.and.ii.le.MAX_DBBC3_IF) then
            itpis_dbbc3(MAX_DBBC3_BBC*2+ii) = 1
         else
            goto 285
         endif
         goto 289
C 
280     ierr = -101
        goto 990
281     ierr = -102
        goto 990
285     ierr = -208
        goto 990
C 
289     continue
        if(ich.gt.nchar) go to 291
290     continue
 291    continue
        do i=1,MAX_DBBC3_DET
           if(itpis_dbbc3(i).ne.0) goto 990
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
