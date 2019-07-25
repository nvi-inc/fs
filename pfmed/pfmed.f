      program pfmed
C
C 1.  PFMED PROGRAM SPECIFICATION
C
C 1.1.   PFMED is a simplified FMGR and EDITR for use in the Mark III field
C        system.  FMGR features are described in FFM and FFMP,
C        EDITR features in FED.
C
C 1.2.   RESTRICTIONS - Only SNAP procedures may be accessed.
C
C 1.3.   REFERENCES - Field system manual
C
C 2.  PFMED INTERFACE
C
C 2.1.   CALLING SEQUENCE: none
C
C 2.2.   COMMON BLOCKS USED:
C
      include '../include/fscom.i'
C
C        LPRC   - current schedule procedure library
C        LNEWSK - next version of procedure file
C        LNEWPR - next version of station procedure file
C
      include 'pfmed.i'
C
C 2.3.   DATA BASE ACCESSES: none
C
C 2.4.   EXTERNAL INPUT/OUTPUT
C
C     INPUT VARIABLES:
C
C     RMPAR      - (1) INPUT LU - DEFAULT = 1
C                  (2) OUTPUT LU - DEFAULT = INPUT
C
C     TERMINAL   - IB
C
C     OUTPUT VARIABLES: ending message
C
C 2.5.   SUBROUTINE INTERFACE:
C
C     CALLING SUBROUTINES: none
C
C     CALLED SUBROUTINES: RMPAR, EXEC, FED, FFM, FFMP, PFCOP
C
C 3.  LOCAL VARIABLES
C
C        ICHI   - number of characters from keyboard
C        LPROC  - active procedure file for PFMED
      dimension ib(51)
C               - line and record buffer
      character*12 lproc
      character cret
      integer fnblnk,ipos
      integer trimlen, rn_take
      logical kerr,kex,kboss
C
C 4.  CONSTANTS USED
C
      character ccol
      character*34 ldef
      character*54 lmdisp
      character*102 cib,cib1
  
C
      data ccol   /':'/
C               - FMGR-like prompt with reverse video
C               - ending message - PFMED ENDED
      data ldef   /'define  nnnnnnnnnnnn  00000000000 '/
C               - DEFINE record - 12 char name begins col. 9,
C                 time field YYDDDHHMMSS begins col. 23
C
C 5.  INITIALIZED VARIABLES
C
      data ib /51*0/, lproc /' '/
C
C 6.  PROGRAMMER: C. Ma
C     LAST MODIFIED: <910327.0454>
C     MODIFIED 840307 BY MWH To add opening messages about procedure files
C     MODIFIED 890505 BY MWH To support CI rather than FMGR files
C  WHO  WHEN    DESCRIPTION
C  GAG  901031  Restructured loop locking files for duration.
C  GAG  901228  Changed IDGET calls to KBOSS calls to see if BOSS is running.
C  GAG  910104  Changed KBOSS call back to IPGST call before scheduling
C               BOSS
C  gag  920910  Added error check after the second rn_take call if BOSS is 
C               running.
C
C     PROGRAM STRUCTURE
C
C     Set input and output LU's.
      call setup_fscom
      call read_fscom
      idcb3=23
      idcb2=22
      idcb1=21
      lui = 6
      if (lui.eq.0) lui=1
      luo=0
      if(luo.eq.0) luo=lui
      kboss_pf=kboss()
C
C     If the Field System is not running, check to see if BOSS is
C     present.
C
      lstp = 'station'
      call char2hol(lstp,ilstp,1,8)
      call fs_set_lstp(ilstp)
      if (.not.kboss_pf) then
        irnprc = rn_take('pfmed',1)
        if (irnprc.eq.1) then
          write(lui,1101) 
1101      format("pfmed is already locked")
          write(lui,1102) 
1102      format("hit return to continue",$)
          read(5,1103) cret
1103      format(a)
          goto 990
        end if
        lprc='none'
        call char2hol(lprc,ilprc,1,8)
        call fs_set_lprc(ilprc)
      else
        irnprc = rn_take('pfmed',1)
        if (irnprc.eq.1) then
          write(lui,1101) 
          write(lui,1102) 
          read(5,1103) cret
          goto 990
        end if
      endif
C
C     Set active procedure file for PFMED to schedule procedure file or
C     station procedure file.
C
C FOLLOWING VARIABLES WERE LOCKED & MAY BE GRABBED ONCE AND SET LATER AT END
      call fs_get_lprc(ilprc)
      call hol2char(ilprc,1,8,lprc)
      call fs_get_lstp(ilstp)
      call hol2char(ilstp,1,8,lstp)
      call fs_get_lnewsk(ilnewsk)
      call hol2char(ilnewsk,1,8,lnewsk)
      call fs_get_lnewpr(ilnewpr)
      call hol2char(ilnewpr,1,8,lnewpr)
      lproc = lprc
      if(lproc.eq.'none') lproc=lstp
C
C  Print messages about current procedure files
C
      lmdisp = 'current active schedule procedure file: ' // lprc(1:8)
      write(lui,2102) lmdisp
2102  format(a)
      if (kboss_pf) then
        lmdisp = 'current active station procedure file:  '// lstp(1:8)
        write(lui,2103) lmdisp
2103    format(a)
      else
        lmdisp = 'current active station procedure file:  none'
        write(lui,2104) lmdisp
2104    format(a)
      endif
      lmdisp = 'procedure file currently open in pfmed: '//
     .    lproc(1:8)
      write(lui,2105) lmdisp
2105  format(a)
C     Copy current procedure file to scratch file 3.
      knewpf = .false.
      call pfcop(lproc,lui,id)
C     Prompt and read input line with echo.
100   write(lui,2106) ccol
2106  format(a,$)
      call ifill_ch(ib,1,40,' ')
      cib1 = ' '
      cib = ' '
      read(5,2928) cib1
2928  format(a)
cxx      write(6,2929) cib1
cxx2929  format(1x,a) ! last two lines only repeat message on the screen
      ichi = 0
      ipos = 1
      ipos = fnblnk(cib1,ipos)
      nch = trimlen(cib1)
      if (nch.gt.0) then
        cib = cib1(ipos:nch)
      end if
      ichi = trimlen(cib)
C     If nothing entered, re-prompt.
      if (ichi.gt.0) then
C       call char2low(cib)
C     If EX or ::, exit.
        if (cib(1:2).eq.'ex'.or.cib(1:2).eq.'::') go to 900
C     Check mode.
        if (cib(1:2).eq.'ed'.or.cib(1:2).eq.'vi'.or.cib(1:5).eq.'emacs')
     &    then
          ierr = 0
          call fed(lui,luo,cib,ichi,lproc,ldef)
        else if (cib(1:2).eq.'pf') then
          call ffm(lui,luo,cib,ichi,lproc,lprc,lstp,lnewsk,lnewpr)
        else
          call ffmp(lui,luo,cib,ichi,lproc,ldef)
        endif
      end if
      goto 100
C     Exit.
900   continue
      call fclose(idcb3,ierr)
      if(kerr(ierr,'pfmed','closing',' ',0,0)) continue
      if (((kboss_pf).and.(.not.kboss())).and.(knewpf)) then !boss was 'offed'
        call fs_get_lnewsk(ilnewsk)
        call hol2char(ilnewsk,1,8,lnewsk)
        if (lnewsk.ne.' ') call reprc(lnewsk)
        call fs_get_lnewpr(ilnewpr)
        call hol2char(ilnewpr,1,8,lnewpr)
        if (lnewpr.ne.' ') call reprc(lnewpr)
      endif
C      ABOUT TO UNLOCK: RESETTING VARS
      call char2hol(lprc,ilprc,1,8)
      call fs_set_lprc(ilprc)
      call char2hol(lstp,ilstp,1,8)
      call fs_set_lstp(ilstp)
      call char2hol(lnewsk,ilnewsk,1,8)
      call fs_set_lnewsk(ilnewsk)
      call char2hol(lnewpr,ilnewpr,1,8)
      call fs_set_lnewpr(ilnewpr)
      call rn_put('pfmed')
      inquire(file=lsf2,exist=kex)
      if (kex) then
        call ftn_purge(lsf2,ierr)
        if(kerr(ierr,'pfmed','purging',' ',0,0)) continue
      end if
990   continue
      write(lui,9300)
9300  format('pfmed ended')
cxx      if (knewpf.and.(ipgst(6hboss  ).ne.-1))
cxx    .    call exec(10,6hboss  ,2hpf)
C
      end






