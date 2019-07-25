      subroutine fm(ip)
C 
C 1.1.   FM controls the formatter
C 
C     INPUT VARIABLES:
C 
      dimension ip(1) 
C        IP(1)  - class number of input parameter buffer. 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - CLASS
C        IP(2) - # REC
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
      include '../include/fscom.i'
C 
C 2.5.   SUBROUTINE INTERFACE:
C     CALLED SUBROUTINES: GTPRM
C 
C 3.  LOCAL VARIABLES 
C        NCHAR  - number of characters in buffer
C        ICH    - character counter 
      integer*2 ibuf(20)                      !  class buffer
      dimension iparm(2)
C               - parameters returned from GTPRM
      dimension ireg(2) 
      integer get_buf
C               - registers from EXEC calls 
C        INP,IMODE,IRATE,ISYN 
C               - indices for input, mode, rate, synch test 
      integer*2 laux(6) 
C              - auxilliary data, from user 
C     NCHAUX - number of chars in aux data
C 
      logical kfmrst
C                - formatter reset
C 
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1)) 
C 
C 4.  CONSTANTS USED
      parameter (ilen=40)                    !  length of ibuf, characters
C 
C 5.  INITIALIZED VARIABLES 
C 
C 6.  PROGRAMMER: NRV
C     LAST MODIFIED:  880127 by LAR - disabled automatic formatter reset
C# LAST COMPC'ED  870115:04:34 #
C
C     PROGRAM STRUCTURE
C
C     1. If we have a class buffer, then we are to set the FM.
C     If no class buffer, we have been requested to read the FM.
C
      do i=1,6
        laux(i) = lauxfm(i)
      enddo
      call fs_get_imodfm(imodfm)
      call fs_get_iratfm(iratfm)
      kfmrst=.false.
      ichold = -99
      iclcm = ip(1)
      if (iclcm.eq.0) then
        ierr = -1
        goto 990
      endif
      call ifill_ch(ibuf,1,ilen,' ')
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2)
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) then
C 
C     2.  This is the read device section.
C     Fill up two class buffers, one requesting ( data (mode -3), 
C     the other ) (mode -4).
C 
        call char2hol('fm',ibuf(2),1,2)
        iclass = 0
        do i=3,4
          ibuf(1) = -i
          call put_buf(iclass,ibuf,-4,'fs','  ')
        enddo
C 
        nrec = 2
C 
C 
      else if (ieq.ne.nchar.and.cjchar(ibuf,ieq+1).eq.'?') then
        ip(1) = 0
        ip(4) = o'77'
        call fmdis(ip,iclcm)
        return
C 
      else if (ichcm(ibuf,ieq+1,ltsrs,1,ilents).eq.0) then
C
C     3. This is the test/reset device section. 
C 
        ibuf(1) = 6
        call char2hol('fm',ibuf(2),1,2)
        iclass=0
        call put_buf(iclass,ibuf,-4,'fs','  ')
        nrec = 1
C
C
      else if (ichcm(ibuf,ieq+1,ltsrs,6,5).eq.0) then
C
C     4. This is the request for a plain reset.
C
        nch = 5
        ibuf(1) = 8
        call char2hol('fm+ ',ibuf(2),1,4)
        iclass = 0
        call put_buf(iclass,ibuf,-nch,'fs','  ')
        kfmrst = .true.
        nrec = 1
C
      else if (ichcm(ibuf,ieq+1,lalrm,1,ilenal).eq.0) then
C
C     5. This is the alarm query and reset request.
C
        ibuf(1) = 7
        call char2hol('fm',ibuf(2),1,2)
        iclass = 0
        call put_buf(iclass,ibuf,-4,'fs','  ')
        nrec = 1
C
      else          ! set formatter
C
C
C     6. Step through buffer getting each parameter and decoding it.
C     Command from user has these parameters:
C                   FM=<output>,<rate>,<input>,<synch>,<aux>,<MATmode>
C     Choices are <input>: NOR, EXT, CRC.  Default NOR.
C                <output>: A, B, C, D.  Default mode B.
C                  <rate>: 0.125,0.25,0.5,1,2,4,8.  Default 4.
C                 <synch>: ON or OFF.  Default ON.
C                   <aux>: auxilliary data, up to 12 hex characters.
C                          Default is current value.
C
C     6.1 OUTPUT, PARAMETER 1
C
        ich = 1+ieq
        ic1 = ich
        call gtprm(ibuf,ich,nchar,0,parm,ierr)
C                   Get the mode, ASCII.  The default mode is B.
        if (cjchar(parm,1).eq.'*') then
          imode = imodfm
        else if (cjchar(parm,1).eq.',') then
          imode = 1
        else
          call ifmed(1,imode,ibuf,ic1,ich-2)
          if (imode.lt.0) then
            ierr = -201
            goto 990
          endif
        endif
C 
C     6.2 SAMPLE RATE, PARAMETER 2
C 
        ic1 = ich
        call gtprm(ibuf,ich,nchar,2,parm,ierr)
C                   Get the sample rate setting, real number
        if (cjchar(parm,1).eq.'*') then
          irate = iratfm
        else if (cjchar(iparm,1).eq.',') then
          irate = 7      !  the default sample rate is 4 mbits
        else
          call ifmed(2,irate,ibuf,ic1,ich-2)
          if (irate.lt.0) then
            ierr = -202
            goto 990
          endif
        endif
C 
C     6.3 INPUT, PARAMETER 3
C 
        ic1=ich
        call gtprm(ibuf,ich,nchar,0,parm,ierr)
        if (cjchar(parm,1).eq.'*') then
          inp = inpfm
        else if (cjchar(parm,1).eq.',') then
          inp = 0      !  defaults to normal
        else
          call ifmed(3,inp,ibuf,ic1,ich-2)
          if (inp.lt.0) then
            ierr = -203
            goto 990
          endif
        endif
C 
C     6.4 SYNCH TEST, PARAMETER 4 
C 
        ic1 = ich
        call gtprm(ibuf,ich,nchar,0,parm,ierr)
        if (cjchar(iparm,1).eq.'*') then
          isyn = isynfm
        else if (cjchar(iparm,1).eq.',') then
          isyn = 1         !  default value is "on"
        else
          call ifmed(4,isyn,ibuf,ic1,ich-2)
          if (isyn.lt.0) then
            ierr = -204
            goto 990
          endif
        endif
C
C     6.5 AUX DATA, PARAMETER 5
C
        ic1 = ich
        call gtprm(ibuf,ich,nchar,0,parm,ierr)
        nchaux = 0
        if (cjchar(parm,1).ne.',') then
C                   If no aux data, skip on
          nchaux = min0(ich-ic1-1,12)
          idumm1 = ichmv(laux,1,lauxfm,1,12)
          idumm1 = ichmv(laux,1,ibuf,ic1,nchaux)
C                   Use max nchaux chars, rest is old AUX field
        endif
C
C     6.6 MAT MODE, PARAMETER 6
C
C260   CALL GTPRM(IBUF,ICH,NCHAR,1,PARM,ierr)
C     IMMODE = 0
C     IF (JCHAR(PARM,1).NE.o'54') IMMODE = IPARM(1)
C     IF (IMMODE.GE.0.AND.IMMODE.LE.5) GOTO 300
C     IERR = -206
C     GOTO 990
C 
C     7. Finally, format the buffer for the controller. 
C     We have a valid LINP,LMODE,RATE,LSYN.  The buffer is set
C     up as follows:
C                   mmFM00000smr  then  ; 
C     where each letter represents a character (half word). 
C                   mm = mode, binary integer 
C                   FM = tells MAT formatter
C                    ; = strobe character for set-up data 
C                   00 = these bits unused
C                   s  = synch test 
C                   m  = input/output mode
C                   r  = sample rate code 
C 
        ibuf(1) = 0
        call char2hol('fm',ibuf(2),1,2)
C        IDUMM1 = ICHMV(IBUF,5,2H; ,1,1)
C                   ***NOTE*** FOR JIM LEVINE'S FORMATTER WE MUST SEND
C                   THE STROBE *AFTER* THE DATA UPDATE
C                   Strobe character for first word 
        call char2hol('00000',ibuf,5,9)
C                   Fill unused fields with zeros 
        idumm1 = ib2as(isyn,ibuf,10,1)
C                   Synch test bit has its own character
        idumm1 = ichmv(ibuf,11,ihx2a(inp*4+imode),2,1)
C                   Put input and output into one word (2 bits each)
        idumm1 = ib2as(irate,ibuf,12,1)
C                   Last character is sample rate 
C 
C 
C     8. Now plant these values into COMMON.
C     Next send the buffer to SAM.
C     Finally schedule BOSS to request that MATCON gets the data. 
C 
        call fs_get_icheck(icheck(17),17)
        ichold = icheck(17)
        icheck(17) = 0
        call fs_set_icheck(icheck(17),17)
        inpfm = inp
        imodfm = imode
        call fs_set_imodfm(imodfm)
        iratfm = irate
        call fs_set_iratfm(iratfm)
        isynfm = isyn
        idumm1 = ichmv(lauxfm,1,laux,1,4)
C 
        iclass=0
        nch = 12
        call put_buf(iclass,ibuf,-nch,'fs','  ')
C 
        nch = 3
        ibuf(1) = 5
        call char2hol('; ',ibuf(2),1,2)
        call put_buf(iclass,ibuf,-nch,'fs','  ')
C                   ***NOTE***SEND THE STROBE CHARACTER AS SEPARATE 
C                   MESSAGE FOR JIM LEVINE'S FORMATTER
C                   USE MODE 5 TO SIMPLY TRANSMIT THIS CHARACTER
        nrec = 2
C
C IF AUX DATA, SEND TWO MORE BUFFERS, WITH ! AND % CONTROLS
        if (nchaux.ne.0) then
C
          ibuf(1) = 0
          call char2hol('fm',ibuf(2),1,2)
          idumm1 = ichmv(ibuf,5,laux,1,8)
          nch = 12
          call put_buf(iclass,ibuf,-nch,'fs','  ')
C                   Send out the first 8 chars ...
          ibuf(1) = 5
          call char2hol('! ',ibuf(2),1,2)
          nch = 3
          call put_buf(iclass,ibuf,-nch,'fs','  ')
C                   ... as ! type data
          ibuf(1) = 0
          call char2hol('fm',ibuf(2),1,2)
          idumm1 = ichmv(ibuf,5,laux,9,4)
          call char2hol('00000',ibuf(9),1,4)
          nch = 12
          call put_buf(iclass,ibuf,-nch,'fs','  ')
C                   Send out the last 4 chars and zeros ...
          ibuf(1) = 5
          call char2hol('% ',ibuf(2),1,2)
          nch = 3
          call put_buf(iclass,ibuf,-nch,'fs','  ')
C                   ... as % type data
          nrec = 6
        endif
      endif
C
C     9. All MATCN requests are scheduled here, and then FMDIS called.
C
      call run_matcn(iclass,nrec)
      call rmpar(ip)
      if(kfmrst) call susp(2,1)
      if (ichold.ne.-99) then
        icheck(17)=ichold
        call fs_set_icheck(icheck(17),17)
      endif
      if (ichold.ge.0) then
        icheck(17)=mod(ichold,1000)+1
        call fs_set_icheck(icheck(17),17)
      endif
      call fmdis(ip,iclcm)
      return
C
990   ip(1) = 0
      ip(2) = 0
      ip(3) = ierr
      call char2hol('qf',ip(4),1,2)
      return
      end
