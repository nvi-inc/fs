      program stqkr
C
C FORTRAN version of stqkr main
C
C     INPUT VARIABLES:
C         IP(1) - class number containing invocation line
C         IP(2) - branch number, encoded
C
C     OUTPUT VARIABLES:
C         IP(1) - class number, if any
C         IP(2) - number of records in class
C         IP(3) - IERR error code return
C         IP(4) - who caused the error
C
C     COMMON BLOCKS USED
      include '../../fs/include/fscom.i'
C
C 3.  LOCAL VARIABLES
      integer*4 ip(5)                     !  rmpar variables
      integer idum,fc_rte_prior
C
C 6.  HISTORY:
C  WHO  WHEN    DESCRIPTION
C  weh  930807  created sample
C
C     PROGRAM STRUCTURE :
C
C  Get RMPAR parameters, then call the subroutine whose number is in IP(2).
C
      call setup_fscom
      call read_fscom
      idum=fc_rte_prior(FS_PRIOR)
C
C  main loop
C
1     continue
      call wait_prog('stqkr',ip)
      call read_quikr
      isub = ip(2)/100
      itask = ip(2) - 100*isub
C
c three examples:
c
      if (isub.eq.1) then
        if (itask.eq.1) then
c         call fm(ip)              replace with station dependent call
        else if (itask.eq.2) then
c         call form4(ip)           replace with station dependent call
        endif
      else if (isub.eq.2) then
c         call xx(ip,itask)        replace with station dependent call
      else if (isub.eq.3) then
c         call xx(ip,isub,itask)   replace with station dependent call
      endif
c
      goto 1
      end
