      SUBROUTINE HDINP(IBUF,ILEN,LU,IERR)

C     This routine reads and decodes one line in the $HEAD section.
C     Call this routine in a loop to get all the head positions
C     filled in.
C
      include '../skdrincl/skparm.ftni'
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen,lu
C      - buffer holding source entry
C     ILEN - length of IBUF in WORDS
C     LU - unit for error messages
C
C  OUTPUT:
      integer ierr
C     IERR - error number
C
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
C
C  LOCAL:
      integer*2 lc,lstn
      integer ip(2*MAX_PASS),ihd(2*MAX_PASS),idir(2*MAX_PASS),
     .istn,n,i,icode
      integer igtfr,igtst ! functions
C
C  History
C  930707 nrv Created.
C 960213 nrv Uppercase the frequency code.
C 960409 nrv Allow second headstack passes
C
C
C     1.   Decode the line.
C 1.5 If there are errors, handle them first.
C
      CALL UNPHD(IBUF,ILEN,IERR,lstn,lc,ip,idir,ihd,n)
      call hol2upper(lc,2) ! uppercase frequency code
C
      IF  (IERR.NE.0) THEN
        IERR = -(IERR+100)
        write(lu,9201) ierr,(ibuf(i),i=2,ilen)
9201    format('FRINP01 - Error in field ',I3,' of:'/40a2)
        RETURN
      END IF 
C
      IF  (IGTST(lstn,istn).EQ.0) THEN !not recognized
        write(lu,9202) lstn,(ibuf(i),i=2,ilen)
9202    format('HDINP01 - Unrecognized station: ',a1,' in line:'/
     .  60a2)
        RETURN
      END IF  !not recognized

      IF  (IGTFR(LC,ICODE).EQ.0) THEN !not recognized
        write(lu,9203) lc,(ibuf(i),i=2,ilen)
9203    format('HDINP01 - Unrecognized frequency code: ',a2,' in line:'/
     .  40a2)
        RETURN
      END IF  !not recognized

C     2. Now store this information
C        ip=list of passes, idir=list of directions,
C        ihd=list of head positions
C        n = number of entries in the lists
C
      do i=1,n
        if (ip(i).lt.100) then ! headstack 1
          ihdpos(ip(i),istn,icode) = ihd(i)
          ihddir(ip(i),istn,icode) = idir(i)
        else ! headstack 2
          ihdpo2(ip(i)-100,istn,icode) = ihd(i)
          ihddi2(ip(i)-100,istn,icode) = idir(i)
        endif
      END DO 
C
      IERR = 0
C
      RETURN
      END
