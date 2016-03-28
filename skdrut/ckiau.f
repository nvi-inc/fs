      subroutine ckiau(ciau,ccom,rarad,decrad,lu)

C    CKIAU generates the IAU name and checks it against
C    the name of the source. Only the first 8 char are
C    checked.
!    2003Dec09 JMGipson changed hollerith to ascii
! If the last character of the iau source name is a character, only check for first 8 characters. 

      include '../skdrincl/skparm.ftni'

C Input
      character*8 ciau, ccom
      integer lu
      real*8 rarad,decrad
      integer ilen 

C Called by: SOINP, WRSOS

C Local:
      character*8 ltest
      character*8 ciau_caps

      call getiauname(ltest,rarad,decrad)
      ciau_caps=ciau
      call capitalize(ciau_caps)
        
      if(index("ABCDEFGHI",ciau_caps(8:8)).ne.0)  then
        ilen=7
      else
        ilen=8
      endif           
!      write(*,*) ilen, ciau_caps

      if(ltest(1:ilen) .ne. ciau(1:ilen) .and. lu .gt. 0) then        
         write(lu,
     >      '("NOTE: IAU name for ",a, " should be ",a " not ",a)')
     >       ccom,ltest,ciau
       endif


      return
      end
