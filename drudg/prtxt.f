      subroutine prtxt

C Print .txt file (if any)
C 980916 nrv Copy from prcov

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'

C Local
      integer i,ierr,ilen
      logical kex

      INQUIRE(FILE=ctextname,EXIST=KEX)
      if (.not.kex) then ! none found
        write(luscn,9100)
9100    format('PRTXT00 -- No notes file was found.')
        return
      endif ! none found

      open(unit=LU_INFILE,file=ctextname,status='old',iostat=IERR)
      if (ierr.ne.0) then
        write(luscn,9101) ierr,ctextname
9101    format('PRCOV01 - Error ',i5,' opening ',a)
        return
      endif

      call setprint(ierr,0)
      CALL READF_ASC(LU_INFILE,IERR,IBUF,ISKLEN,ILEN)
      DO WHILE (IERR.GE.0.AND.ILEN.NE.-1)
        write(luprt,'(80a2)') (ibuf(i),i=1,ilen)
        CALL READF_ASC(LU_INFILE,IERR,IBUF,ISKLEN,ILEN)
      enddo

      close(luprt)
      call prtmp(0)
      return
      end
