C@skTIME
      subroutine sktime(cbuf,ctime)
C
C     sktime: returns the time field for an observation record
      include '../skdrincl/skparm.ftni'
! 2005Nov30 JMGipson. Rewritten to use ascii.

C  INPUT VARIABLES
      character*(*) cbuf  !buffer holding observation.
! Output
      character*12 ctime

! local
      integer MaxToken
      integer NumToken
      parameter(MaxToken=10)
      character*16 ltoken(MaxToken)

      call splitNtokens(cbuf,ltoken,Maxtoken,NumToken)

      ctime=ltoken(5)
      return
      end
