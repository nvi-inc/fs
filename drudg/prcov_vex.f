      subroutine prcov_vex

C Print PI cover letter from VEX files
C 000516 nrv New.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
      include 'drcom.ftni'

C Local
      integer jchar,i,ierr,ilen

      if (ireccv.eq.0) then ! none found
        write(luscn,9100)
9100    format('PRCOV00 -- No cover letter info was found.')
        return
      endif ! none found

      close(unit=LU_INFILE)
      open(unit=LU_INFILE,file=LSKDFI,status='old',iostat=IERR)
      if (ierr.ne.0) then
        write(luscn,9101) ierr,lskdfi
9101    format('PRCOV01 - Error ',i5,' opening ',a)
        return
      endif

      call setprint(ierr,0)
      do i=1,ireccv
        CALL READF_ASC(lu_infile,iERR,IBUF,ISKLEN,ILen)
      enddo
      CALL READF_ASC(LU_INFILE,IERR,IBUF,ISKLEN,ILEN)
      DO WHILE (IERR.GE.0.AND.ILEN.NE.-1.AND.JCHAR(IBUF,1).NE.odollar)
        write(luprt,'(80a2)') (ibuf(i),i=1,ilen)
        CALL READF_ASC(LU_INFILE,IERR,IBUF,ISKLEN,ILEN)
      enddo

      close(luprt)
      call prtmp(0)
      return
      end
