      subroutine lxskd
C
C  COMMON BLOCKS USED:
C 
      include '../include/fscom.i'
      include 'lxcom.i'
C 
C      CALLING SUBROUTINES: 
C 
C      File manager package routines
C      Character manipulation routines
C 
C  LOCAL VARIABLES: 
C 
      character*79 outbuf
      integer answer, nchar, trimlen, ichmv
      character cjchar
      dimension iparm(2)
C 
      equivalence (parm,iparm(1))
C 
C  INITIALIZED VARIABLES:
C
      data n/1/ 
C 
C 
      if (iscn_ch(ibuf,1,nchar,'=').ne.0) goto 1410
      if (isked.eq.0) call po_put_c(' none specified')
      if (isked.eq.1) then
        outbuf='sked=' // lsknc
        call po_put_c(outbuf)
      endif
      goto 1700
C
C Get SKED namr
C
1410  ich=ieq+1
      ic1=ich
      isked=0
      call gtprm(ibuf,ich,nchar,0,parm,id)
      istrc=ich-2
      lsknc=' '
      ilength=ich-ic1-1
C
      if (ilength.le.0) then
        call po_put_c('No sked name given')
        goto 1700
      end if
C
      id = ichmv(lskna,1,ibuf,ic1,ilength)
      call char2low(lsknc)
      call fmpopen(idcbsk,lsknc,ierr,'r+',idum)
C
      if (ierr.ge.0) goto 1430
        outbuf='LXSKD60 - error '
        call ib2as(ierr,answer,1,4)
        call hol2char(answer,1,4,outbuf(17:))
        nchar = trimlen(outbuf) + 1
        outbuf(nchar:)=' opening schedule file ' //lsknc
        call po_put_c(outbuf)
        icode=-1
        goto 1700
C
C Get schedule start time
C
1430  ic2=ich
      isked=1
      call gtprm(ibuf,ich,nchar,1,parm,id)
      if (cjchar(parm,1).ne.',') goto 1440
      itsk1=0
      itsk2=0
      itsk3=0
      goto 1460
C
C Call GTTIM to decode snap time format
C
1440  call gttim(ibuf,ic2,ich-2,0,itsk1,itsk2,itsk3,ierr)
      if (ierr.ge.0) goto 1450
        outbuf='LXSKD70 - error sp '
        call ib2as(ierr,answer,1,4)
        call hol2char(answer,1,4,outbuf(20:))
        nchar = trimlen(outbuf) + 1
        outbuf(nchar:)=' schedule start time'
        call po_put_c(outbuf)
        icode=-1
        goto 1700
C
C Store calculated start schedule day in ITSK1
C
1450  continue
C     itsk1=mod(itsk1,1024)
C
C Get the schedule stop time
C
1460  ic3=ich
      call gtprm(ibuf,ich,nchar,1,parm,id)
      if (cjchar(parm,1).ne.',') goto 1470
C not Y2038K compliant
      itske1=(2038-1970)*1024+1
      itske2=0
      itske2=0
      goto 1700
1470  call gttim(ibuf,ic3,ich-2,0,itske1,itske2,itske3,ierr)
      if (ierr.ge.0) goto 1480
        outbuf='LXSKD80 - error sp '
        call ib2as(ierr,answer,1,4)
        call hol2char(answer,1,4,outbuf(20:))
        nchar = trimlen(outbuf) + 1
        outbuf(nchar:)=' schedule stop time'
        call po_put_c(outbuf)
        icode=-1
        goto 1700
1480  continue
c     itske1=mod(itske1,1024)
C
1700  continue
      return
      end
