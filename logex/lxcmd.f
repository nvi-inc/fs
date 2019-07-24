      subroutine lxcmd
C
C LXCMD - Reads one command entry at a time.
C
C MODIFICATIONS:
C
C    DATE     WHO  DESCRIPTION
C    820909   KNM  SUBROUTINE CREATED
C
C COMMON BLOCKS USED:
C
      include 'lxcom.i'
C
C SUBROUTINE INTERFACES:
C    CALLED SUBROUTINES:
C    LOGEX - Main program
C
C    CALLING SUBROUTINES
C    File manager package routines
C
C LOCAL VARIABLES:
      integer fblnk, answer, trimlen
      integer fmpread
      character*79 outbuf
C
C
C  ****************************************************************
C
C  1. Read the Command file and check for a break.
C
C  ****************************************************************
C
C
      call ifill_ch(ibuf,1,iblen*2,' ')
      id = fmpread(idcbcm,ierr,ibuf,iblen*2)
      nchar=iflch(ibuf,iblen*2)
      call upper(ibuf,1,nchar)
      nchar = fblnk(ibuf,1,nchar)
      if (nchar.eq.0) il = -1
      if(ierr.ge.0) goto 100
        outbuf='LXCMD10 - error '
        call ib2as(ierr,answer,1,4)
        call hol2char(answer,1,4,outbuf(17:))
        nchar = trimlen(outbuf) +1
        outbuf(nchar:) = 'reading command file ' //namcmc
        call po_put_c(outbuf)
        icode=-1
        goto 200
cxx100   if(ifbrk(idum).lt.0) icode=-1
100     continue
      if (icmd.eq.1) call po_put_i(ibuf,nchar)
C
200   continue
      return
      end
