      subroutine getcm(istksk,istkop,lstksk,lstkop,idcbp1,idcbp2,idcbsk,
     .            kblksk,kblkop,khalt,kbreak,iclopr,iclop2,
     .            iblen,ibuf,nchar,lsor,lprocs,lproco,lpparm,ncparm,
     .            lnames,nnames,lproc1,nproc1,lproc2,nproc2,
     .            maxpr1,maxpr2,ierr,icurln,ilstln,iwait)
C
C     GETCM - gets the next command for BOSS to process
C
C     DATE   WHO CHANGES
C     810907 NRV Added procedure arrays
C     840320 MWH Added support for specified # of schedule lines to execute
C     880511 LAR Fixed it so immediate execution really works
C
C  INPUT VARIABLES:
      dimension istksk(1),istkop(1),lstksk(1),lstkop(1)
C     Stacks for procedure names and parameters
      dimension idcbp1(1),idcbp2(1),idcbsk(1)
C     DCB'S for procedure files, schedule
      dimension lnames(13,1)
      integer*4 lproc1(4,1),lproc2(4,1)
C     Arrays with command names
      logical kblksk,kblkop
C     True when schedule/operator stream is blocked
      logical khalt
C     True when HALT was issued to block schedule
      logical kbreak
C     True when operator asks for a procedure to be ended early
C
C  OUTPUT VARIABLES:
C
      integer*2 ibuf(1)
C     Buffer with new command
C     IBLEN  - max length of IBUF in words
C     NCHAR  - number of characters in command in IBUF
C     LSOR   - source of command - schedule, operator, procedure
      dimension lpparm(1)
C     Parameters string
C     NCPARM - number of chars in LPPARM
C     IERR  - error return, non-zero FMP error
C
C  LOCAL VARIABLES:
C
      integer*4 irec,ioff,icurln,ilstln
      integer fblnk, fmpposition, get_buf
      character cjchar
      dimension ireg(2)
      equivalence (ireg(1),reg)
C
C     1. Initialize error return and number of characters.
C
      nchar = 0
      ierr = 0
C
C     2. First sift through all of the operator class stack to see if
C     there are any "immediate execution" commands to be processed
C     or any time-scheduling commands.
C     If so, then that's our highest priority.
C
200   continue
      iwait = 0
      ireg(2) = get_buf(iclopr+o'120000',ibuf,-iblen*2,idum,iwait)
      nchar = iflch(ibuf,min0(ireg(2),iblen*2))
      nchar = fblnk(ibuf,1,nchar)
      do i=1,nchar
         if(cjchar(ibuf,i).eq.'"') goto 201
         if(cjchar(ibuf,i).ne.' ') then
            call lower(ibuf,nchar)
            goto 201
         endif
      enddo
 201  continue
      if (ireg(1).lt.0) nchar = 0
      if (nchar.eq.0) goto 300
C                   When there's nothing there, that's the
C                   end of the class records
      if (jchar(ibuf,1).gt.o'42'.or.jchar(ibuf,1).lt.o'41') then
C                   Don't bother with comments (") or wait commands (!)
        ich = iscn_ch(ibuf,1,nchar,'=')
        if (ich.eq.0) then
          ich = iscn_ch(ibuf,1,nchar,'@')
          ich = nchar+1
        endif
        call gtnam(ibuf,1,ich-1,lnames,nnames,lproc1,nproc1,lproc2,
     &    nproc2,ierr,itype,index)
        call char2hol(';;',lsor,1,2)
C                    Immediate-execute functions and time-scheduled
C                                      functions have priority.
        if (ichcm_ch(itype,2,'F').eq.0 .and. ierr.eq.0 .and.
     &    (cjchar(lnames(7,index),1).eq.'*' .or.
     &    iscn_ch(ibuf,1,nchar,'@').ne.0)) return
      endif
      ierr = 0      !  reset error flag from gtnam, we'll discover it later
      call put_bufi(iclop2,ibuf,-nchar,'fs',iwait)
C                   In this case, it's an ordinary command.  Put it into
C                   the secondary operator class for later pick-up.
      goto 200
C
C
C     3. First try to read something into the schedule stream.
C     If the schedule is blocked or a HALT was issued, try the
C     operator stream.
C
300   continue
      if (.not.khalt .and. .not.kblksk) then
        if (istksk(2).ne.2) then
C                   If we have nothing in the procedure stack
C                   try to get next line in schedule file
          call readp(idcbp1,idcbp2,istksk,lstksk,lproc1,lproc2,kbreak,
     &      ibuf,iblen,nchar,lprocs,lpparm,ncparm,ierr)
          if (istksk(2).ne.2 .and. ierr.ne.-1) then
C                   If there's nothing left, go back to schedule file
            call char2hol('$:',lsor,1,2)
            return
          endif
        endif
C
        call newpf(idcbp1,idcbp2,lproc1,maxpr1,nproc1,lproc2,maxpr2,
     &    nproc2,ibuf,iblen,istkop,istksk)
        if (icurln.lt.ilstln) then
          call reads(idcbsk,ibuf,iblen,nchar,ierr)
          idum = fmpposition(idcbsk,ierr,irec,ioff)
          icurln = icurln + 1
          if(nchar.eq.0) then
            ierr = 0
            icurln = icurln-1
          endif
          call char2hol('::',lsor,1,2)
          if (nchar.eq.0) kblksk = .true.
          ncparm = 0
          return
        else
          khalt=.true.
          call fs_set_khalt(khalt)
          ilstln=100000
        endif
      endif
C
C     4. As second choice, try to get something into the operator stream.
C     First, read from the operator-invoked procedure file.
C     Then, check the operator mail-box for a command.
C
      if (kblkop) return
      if (istkop(2).ne.2) then
C                   If there is nothing in the procedure stack, try to
C                   get something from mailbox
        call readp(idcbp1,idcbp2,istkop,lstkop,lproc1,lproc2,kbreak,
     &    ibuf,iblen,nchar,lproco,lpparm,ncparm,ierr)
        if (istkop(2).ne.2 .and. ierr.ne.-1) then
          call char2hol('$;',lsor,1,2)
          return
        endif
      endif
C
      call newpf(idcbp1,idcbp2,lproc1,maxpr1,nproc1,lproc2,maxpr2,
     .nproc1,ibuf,iblen,istkop,istksk)
      ncparm = 0
      if (iclop2.gt.0) then
        ireg(2) = get_buf(iclop2+o'120000',ibuf,-iblen*2,idum,iwait)
        nchar = iflch(ibuf,min0(ireg(2),iblen*2))
        if (ireg(1).lt.0) nchar = 0
      end if
      call char2hol(';;',lsor,1,2)
C
      return
      end
