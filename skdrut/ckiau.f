      subroutine ckiau(ciau,ccom,rarad,decrad,lu)

C    CKIAU generates the IAU name and checks it against
C    the name of the source. Only the first 8 char are
C    checked.
!    2003Dec09 JMGipson changed hollerith to ascii

      include '../skdrincl/skparm.ftni'

C Input
      character*8 ciau, ccom
      integer lu
      real*8 rarad,decrad

C Called by: SOINP, WRSOS

C Local:
      character*8 ltest

      call getiauname(ltest,rarad,decrad)

      if(ltest .ne. ciau .and. lu .gt. 0) then
         write(lu,
     >    '("NOTE: IAU name for ",a, " should be ",a " not ",a)')
     >    ccom,ltest,ciau
      endif

      return
      end
