      subroutine setup_name(lcode,cnamep) 
      implicit none 
C SETUP_NAME generates the setup procedure name.
! passed.
      character*(*) lcode
! returned
      character*12 cnamep 
! 2014Jan17 JMG. Since we no longer have passes, made much simpler.
! functions    
      integer trimlen    
! local
   
      cnamep='setup'//lcode(1:trimlen(lcode))
      call lowercase(cnamep)    
      return
      end
