      subroutine tplisn(ip,itpis_norack)
C  parse tpi list c#870115:04:30# 
C 
C 1.1.   TPLISN parses the list of possible detectors for "none" racks
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
      integer itpis_norack(1)
C      - TPIs requested, 0=not wanted, 1=get it 
C        IP(3) - ERROR RETURN 
C        IP(4) - who we are 
C 
C     CALLED SUBROUTINES: FDFLD,JCHAR,DTNAM 
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
C                   u5 - user detector 5
C                   u6 - user detector 6
C 
      do i=1,2
        itpis_norack(i) = 0
      enddo
C                   Turn off all of the TPIs to start 
      ich = 1+ieq 
      do 290 i=1,2 
        call fdfld(ibuf,ich,nchar,ic1,ic2)
        if (ic1.eq.0) then
          if (i.eq.1) then        !  if no parameters, error
             ierr=-212
             goto 990
          endif
          goto 990
        endif
        inumb=ic2-ic1+1
        inumb=min(inumb,8)
        idum = ichmv(iprm,1,ibuf,ic1,inumb)
        ich=ic2+2 !! point beyond next comma
C                   Pick up each parameter as characters
        if (cjchar(iprm,1).eq.'*') then
           ierr=-213
           goto 990
        endif

220     if (ichcm_ch(iprm,1,'u5').ne.0) goto 225
        itpis_norack(1) = 1
        goto 290
C
225     if (ichcm_ch(iprm,1,'u6').ne.0) goto 230
        itpis_norack(2) = 1
        goto 290
C 
 230    continue
        ierr=-214
        goto 990
C 
290     continue
C 
C 
C     3. We are finished with our job.
C 
990   ip(3) = ierr
      call char2hol('qk',ip(4),1,2)
      return
      end 
