      subroutine tplisl(ip,itpis_lba)
C  parse tpi list c#870115:04:30# 
C 
C 1.1.   TPLISL parses the list of possible TPI detectors for
C        an LBA rack.
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
      integer itpis_lba(1)
C      - TPIs requested, 0=not wanted, 1=get it 
C        IP(3) - ERROR RETURN 
C        IP(4) - who we are 
C 
C     CALLED SUBROUTINES: FDFLD,JCHAR,DTNAM 
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
C                   FORMIFP - IFPs being recorded
C                   IFP - gets P1 to 16
C                   EVEN - even-numbered IFPs
C                   ODD - odd-numbered IFPs
C                   IFPn - gets IFPn
C 
      call fs_get_ndas(ndas)
      do i=1,2*ndas
        itpis_lba(i) = 0
      enddo
C                   Turn off all of the TPIs to start 
      ich = 1+ieq 
      do 290 i=1,2*ndas
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
        if (ichcm_ch(iprm,1,'formifp').ne.0) goto 210
        call fc_lbaifpd(itpis_lba)
        goto 289
c
210     continue
        if (ichcm_ch(iprm,1,'all').ne.0) goto 220
        do ii=1,2*ndas
          itpis_lba(ii) = 1
        enddo
        goto 289
 
220     if (ichcm_ch(lprm,1,'ip').ne.0) goto 225
        do ii=1,2*ndas
          itpis_lba(ii) = 1
        enddo
        goto 289
C
225     if (ichcm_ch(iprm,1,'odd').ne.0) goto 230
        do ii=1,2*ndas-1,2
          itpis_lba(ii) = 1
        enddo
        goto 289
C 
230     if (ichcm_ch(iprm,1,'even').ne.0) goto 240
        do ii=2,2*ndas,2
          itpis_lba(ii) = 1
        enddo
        goto 289
C
240     continue
        if (lprm.eq.0) goto 285
        if (ichcm_ch(lprm,1,'p').ne.0) goto 285
        if (((cjchar(lprm,2).ge.'1').and.(cjchar(lprm,2).le.'9')).or.
     .      ((cjchar(lprm,2).ge.'a').and.(cjchar(lprm,2).le.'f'))) then
          ii=jchar(lprm,2) - o'60'  !! turns hollerith into integer
          if (ii.gt.9) ii=ii-39  !! if a thru f subtract to get correct
C                              !! integer
          if (ii.lt.1 .or. ii.gt.2*ndas) goto 285
          itpis_lba(ii) = 1
          goto 289
        endif
        goto 289
C 
280     ierr = -101
        goto 990
 281    ierr=  -102
        goto 990
285     ierr = -203
        goto 990
C 
289     continue
        if(ich.gt.nchar) go to 291
290     continue
 291    continue
        do i=1,2*ndas
           if(itpis_lba(i).ne.0) goto 990
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
