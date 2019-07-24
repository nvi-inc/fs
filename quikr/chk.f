      subroutine chk(ip)
C  check command
C 
C  CHK parses the list of module mnemonics to be checked.
C 
C  COMMON:
      include '../include/fscom.i'
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of input parameter buffer
C        IP(2-5)- not used
C 
C     OUTPUT VARIABLES: 
C        IP(1) - class response 
C        IP(2) - number of records
C        IP(3) - ERROR RETURN 
C        IP(4) - who we are 
C 
C     CALLED SUBROUTINES: FDFLD,JCHAR 
C 
C   LOCAL VARIABLES 
      integer*2 lprm,mdnam
      integer ichcm_ch
      logical kminus
C               - true if parameter is preceded by a minus sign 
      logical kMrack, kMdrive
C               - true for MK3 rack and drive, respectively
C               - if false, then VLBA rack or drive, respectively
      dimension ick(20) 
      integer ickv(20)
C      - parameters to this command 
C        ICH    - character counter 
C     NCHAR  - character count
      integer*2 ibuf(50)
C               - class buffer, holding command 
C        ILEN   - length of IBUF, chars 
      integer*2 iprm(4)
C               - parameters returned from FDFLD
      dimension ireg(2) 
      integer get_buf
C               - registers from EXEC calls 
      character cjchar
      equivalence (reg,ireg(1)) 
C 
C   INITIALIZED VARIABLES 
      data ilen/100/
C 
C  PROGRAMMER: NRV
C  HISTORY:
C  WHO  WHEN    WHAT
C  MWH  840308  changed from NOCHECK to CHECK, added * option
C  MWH  840703  added RX to list of checkable modules
C  gag  920714  Changed rack and drive logicals to be valid for Mark IV.
C               also.
C  gag  920930  Clean up with the differences between vlba and Mk3/4. 
C 
C 
C     1. If class buffer contains command name with "=" then we have
C     parameters to get the modules.  If only the command name is present,
C     then list the modules being checked.
C 
      iclcm = ip(1) 
      do i=1,3
        ip(i)=0
      enddo
      call char2hol('qn',ip(4),1,2)
      if (iclcm.eq.0) then
        ip(3) = -1
        return
      endif  
      call ifill_ch(ibuf,1,ilen,' ')
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
      ieq = iscn_ch(ibuf,1,nchar,'=')
      kMrack=.false.
      kMdrive=.false.
      call fs_get_rack(rack)
      call fs_get_drive(drive)
      if ((MK3.eq.iand(rack,MK3)).or.(MK4.eq.iand(rack,MK4)))
     . kMrack = .true.
      if ((MK3.eq.iand(drive,MK3)).or.(MK4.eq.iand(drive,MK4)))
     . kMdrive = .true.
      if (ieq.eq.0) goto 500
C                   If no parameters, go report current list
C 
C     2. Step through buffer getting each parameter and decoding it.
C     Command from user looks like: 
C                   CHECK=<list>
C     Mark III parameters:
C                   V1 to V15 - video converters
C                   VC - all video converters (1 to 15) 
C                   IF - IF distributor 
C                   FM - formatter
C                   TP - tape 
C                   HD - high density heads
C     VLBA parameters:
C                   B1 to B16 - baseband converters
C                   IA - IF distributor, channels A & B
C                   IC - IF distributor, channels C & D
C                   FM - formatter
C                   RC - tape recorder
C     Other modules:
C                   RX - S/X receiver
C                   ALL - all modules 
C                   ODD - video converters 1,3,5,7,9,11,13
C                   EVEN - video converters 2,4,6,8,10,12,14
C                   NULL - do not check anything
C 
C  FIRST CHECK WHAT TYPE OF RACK AND THEN SET APPROPRIATE
C  ARRAYS FOR THE TYPE OF RACK

C Turn off all of the parameters to start 
      do i=1,20 
        ick(i) = 0
        ickv(i) = 0
      enddo
C
      ich = 1+ieq 
C  Handle * if present
      if (cjchar(ibuf,ich).eq.'*') then
        do i=1,20 
          call fs_get_icheck(icheck(i),i)
          call fs_get_ichvlba(ichvlba(i),i)
          if (icheck(i).gt.0) ick(i)=1
          if (ichvlba(i).gt.0) ickv(i)=1
        enddo
        ich=ich+2 
      endif
C
C  Top of loop to handle all input!!
201   continue
C  Handle minus sign if present 
        kminus = (cjchar(ibuf,ich).eq.'-')
        if (kminus) then
          ich = ich+1
          iset = 0
        else
          iset = 1
        endif
        call fdfld(ibuf,ich,nchar,ic1,ic2)
        if (ic1.eq.0) goto 210 
        inumb=ic2-ic1+1
        inumb=min(inumb,8)
        idum = ichmv(iprm,1,ibuf,ic1,inumb)
        ich=ic2+2 !! point beyond next comma
C                   Pick up each parameter as characters
        lprm=mdnam(iprm,1,inumb)
C
C  2.1 Get 2-character mnemonic 
C    First check for RX (MDNAM doesn't recognize RX)
        if (ichcm_ch(iprm(1),1,'rx').eq..0) then
          ick(19) = iset 

C 
C  2.2 First check for ALL.
C 
        else if (ichcm_ch(lprm,1,'al').eq.0) then
          if (kMrack) then
            do i=1,17
              ick(i) = iset
            enddo
          else
            do i=1,19
              ickv(i) = iset
            enddo
          endif
          ick(19) = iset
          ick(20) = iset
          if (kMdrive) then
            ick(18) = iset
          else
            ickv(20) = iset
          endif
C 
C  2.3 Try for EVEN. 
C 
        else if (ichcm_ch(lprm,1,'ev').eq.0) then
          do i=2,14,2
            if (kMrack) then
              ick(i) = iset
            else
              ickv(i) = iset
            endif
          enddo
          if (.not.kMrack) ickv(16) = iset
C 
C  2.4 Might be ODD. 
C 
        else if (ichcm_ch(lprm,1,'od').eq.0) then
          do i=1,13,2
            if (kMrack) then
              ick(i) = iset
            else
              ickv(i) = iset
            endif
          enddo
          if (.not.kMrack) ickv(15) = iset
C
C  2.5 Now check for HD
C
        else if (ichcm_ch(iprm(1),1,'hd').eq.0) then
          ick(20) = iset 
C 
C  2.6 One of the video converters.
C 
        else if ((cjchar(lprm,1).eq.'v').and.(kMrack)) then
          ii=jchar(lprm,2)-z'30'
          if (ii.gt.9) ii=ii-7-z'20'
          if (ii.le.0 .or. ii.gt.15) then
            ip(3) = -201
            return
          endif
          ick(ii) = iset
C
C  2.7 One of the baseband converters.
C
        else if ((cjchar(lprm,1).eq.'b').and.(.not.kMrack)) then
          ii=jchar(lprm,2)-z'30'
          if (ii.gt.9) ii=ii-7-z'20'
          if (ii.le.0 .or. ii.gt.16) then
            ip(3) = -301
            return
          endif
          ickv(ii) = iset
C 
C  2.8 IF distributor
C 
        else if ((ichcm_ch(lprm,1,'if').eq.0).and.(kMrack)) then
          ick(16) = iset

        else if ((ichcm_ch(lprm,1,'ia').eq.0).and.(.not.kMrack)) then
          ickv(17) = iset

        else if ((ichcm_ch(lprm,1,'ic').eq.0).and.(.not.kMrack)) then
          ickv(18) = iset
C 
C  2.9 Formatter 
C 
        else if ((ichcm_ch(lprm,1,'fm').eq.0).and.(kMrack)) then
          ick(17) = iset

        else if ((ichcm_ch(lprm,1,'fm').eq.0).and.(.not.kMrack)) then
          ickv(19) = iset
C 
C  2.10 Tape (MK3)
C 
        else if ((ichcm_ch(lprm,1,'tp').eq.0).and.(kMdrive)) then
          ick(18) = iset
C 
C  2.11 Recorder (VLBA) 
C 
        else if ((ichcm_ch(lprm,1,'rc').eq.0).and.(.not.kMdrive)) then
          ickv(20) = iset 
C 
C     2.99 None of the above
C 
        else
          ip(3) = -201
          return
        endif
        goto 201
C
210     do i=1,20 
          call fs_get_icheck(icheck(i),i)
          call fs_get_ichvlba(ichvlba(i),i)
          if (ick(i).eq.0.and.icheck(i).gt.0) icheck(i) = -1
          if (ickv(i).eq.0.and.ichvlba(i).gt.0) ichvlba(i) = -1
C             If the module was set up, don't check it now
          if (ick(i).eq.1.and.icheck(i).lt.0) icheck(i) = +1
          if (ickv(i).eq.1.and.ichvlba(i).lt.0) ichvlba(i) = +1
C             If the module was previously ignored, check it now
          call fs_set_icheck(icheck(i),i)
          call fs_set_ichvlba(ichvlba(i),i)
        enddo
C 
      goto 900
C 
C     5. Report the modules currently being checked.
C 
500   continue
C  check kMrack
C  if true then list mk3 rack oriented mnemonics
C  else if false then list vlba rack oriented mnemonics
C  check kMdrive 
C  if true then list mk3 drive oriented mnemonics
C  else if false then list vlba drive oriented mnemonics
C
      nch = ichmv(ibuf,nchar+1,2H/ ,1,1)
      if (kMrack) then    !! if MK3 rack
        do i=1,17
          call fs_get_icheck(icheck(i),i)
          if (icheck(i).ge.1) then
            if (i.le.15) then
              nch = ichmv(ibuf,nch,2Hv ,1,1)
              nch = nch + ib2as(i,ibuf,nch,o'100000'+2)
            else
              if (i.eq.16) nch = ichmv(ibuf,nch,2Hif,1,2)
              if (i.eq.17) nch = ichmv(ibuf,nch,2Hfm,1,2)
            endif
            nch = mcoma(ibuf,nch)
          endif
        enddo
      else        !! if VLBA rack
        do i=1,19
          call fs_get_ichvlba(ichvlba(i),i)
          if (ichvlba(i).ge.1) then
            if (i.le.16) then
              nch = ichmv(ibuf,nch,2Hb ,1,1)
              nch = nch + ib2as(i,ibuf,nch,o'100000'+2)
            else
              if (i.eq.17) nch = ichmv(ibuf,nch,2Hia,1,2)
              if (i.eq.18) nch = ichmv(ibuf,nch,2Hic,1,2)
              if (i.eq.19) nch = ichmv(ibuf,nch,2Hfm,1,2)
            endif
            nch = mcoma(ibuf,nch)
          endif
        enddo
      endif
C
      if (kMdrive) then   !! if MK3 drive
        call fs_get_icheck(icheck(18),18)
        if (icheck(18).ge.1) then
          nch = ichmv(ibuf,nch,2Htp,1,2)
          nch = mcoma(ibuf,nch)
        endif
      else   !! if VLBA drive
        call fs_get_ichvlba(ichvlba(20),20)
        if (ichvlba(20).ge.1) nch = ichmv(ibuf,nch,2Hrc,1,2)
        nch = mcoma(ibuf,nch)
      endif
      call fs_get_icheck(icheck(19),19)
      if (icheck(19).ge.1) then
        nch = ichmv(ibuf,nch,2Hrx,1,2)
        nch = mcoma(ibuf,nch)
      endif
      call fs_get_icheck(icheck(20),20)
      if (icheck(20).ge.1) then
        nch = ichmv(ibuf,nch,2Hhd,1,2)
        nch = mcoma(ibuf,nch)
      endif
C
      nch=nch-1
      if (ichcm_ch(ibuf,nch,',').eq.0) nch=nch-1
      if (ichcm_ch(ibuf,nch,'/').eq.0)
     +  nch=ichmv(ibuf,nch+1,8Hdisabled,1,8)-1
C 
      iclass = 0
      call put_buf(iclass,ibuf,-nch,2Hfs,0)
      ip(1) = iclass
      ip(2) = 1

900   continue
      return
      end 
