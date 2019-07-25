      subroutine lxcfl
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
C 
C 
C Scan for an equals sign.
C
      if (iscn_ch(ibuf,1,nchar,'=').ne.0) goto 1510
      if (icmd.eq.0) call po_put_c(' none specified')
      if (icmd.eq.1) then
        outbuf='cfile=' // namcmc
        call po_put_c(outbuf)
      endif
      goto 1700
C
C Close command file if we are requesting a new file to be opened.
C Then obtain the command file name and open it.
C
1510  call fmpclose(idcbcm,ierr)
      istrc=ieq+1
      namcmc=' '
      id = ichmv(namcm,1,ibuf,istrc,nchar-istrc+1)
      call char2low(namcmc)
      call fmpopen(idcbcm,namcmc(1:nchar-istrc+1),ierr,'r',idum)
      if (ierr.ge.0) goto 1530
        outbuf='LXCFL90 - error '
        call ib2as(ierr,answer,1,4)
        call hol2char(answer,1,4,outbuf(17:))
        nchar = trimlen(outbuf) + 1
        outbuf(nchar:)=' opening command file ' // namcmc
        call po_put_c(outbuf)
        icode=-1
        goto 1700
1530  icmd=1
C
1700  continue
      return
      end
