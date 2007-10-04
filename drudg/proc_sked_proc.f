      subroutine proc_sked_proc(ierr)
! Write out procedures from sked file if there are any.
      include 'hardware.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      integer ierr

! functions
      integer ichmv

! local
      LOGICAL KUS ! true if our station is listed for a procedure
      integer ilen, ich, ic1, ic2,nch
      integer*2 IBUF2(40) ! secondary buffer for writing files
      character*80 cbuf2
      equivalence (ibuf2,cbuf2)
      logical kcomment
      character*12 cnamep


      open(unit=LU_INFILE,file=LSKDFI,status='old',iostat=IERR)
      if (ierr.ne.0) then
        write(luscn,9991) ierr,lskdfi
9991    format('PROCS91 - Error ',i5,' opening ',a)
        return
      endif

      CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
      DO WHILE (IERR.GE.0.AND.ILEN.NE.-1.AND.cbuf(1:1) .ne. "$")
C       read $PROC section
        ICH = 1
        KUS=.FALSE.
        CALL GTFLD(IBUF,ICH,ILEN,IC1,IC2)

        if(ic1 .lt. ic2 .and. ic1 .ne. 0) then
           kus=index(cbuf(ic1:ic2),cstcod(istn)(1:1)) .ne. 0
        endif
C
        IF (KUS) THEN ! a proc for us
          CALL GTFLD(IBUF,ICH,ILEN,IC1,IC2)
          IF (IC1.NE.0) THEN ! write proc file
            cnamep=" "
            nch=min0(ic2-ic1+1,12)
            cnamep=cbuf(ic1:ic1+nch-1)
            call proc_write_define(lu_outfile,luscn,cnamep)
            CALL GTSNP(ICH,ILEN,IC1,IC2,kcomment)
            DO WHILE (IC1.NE.0) ! get and write commands
              cbuf2=" "
              NCH = ICHMV(IBUF2,1,IBUF,IC1,IC2-IC1+1)
              if (.not.kcomment) call lowercase(cbuf2(1:nch))
              write(lu_outfile,'(a)') cbuf2(1:nch)
              CALL GTSNP(ICH,ILEN,IC1,IC2,kcomment)
            ENDDO ! get and write commands
            write(lu_outfile,"('enddef')")

          ENDIF ! write proc file
        ENDIF ! a proc for us
        CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
      ENDDO ! read $PROC section

      return
      end

