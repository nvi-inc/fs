      subroutine proc_tapef_name(code,cpmode,cnamep)
      include 'hardware.ftni'
! passed
      character*2 code
      character*4 cpmode
! returned
      character*12 cnamep
! function
      integer trimlen
! local
      integer nch1
      integer nch2

      nch1=trimlen(code)
      nch2=trimlen(cpmode)
      cnamep="tapef"//code(1:nch1)//cpmode(1:nch2)
      nch1=nch1+nch2+6
      if (krec_append) cnamep(nch1:nch1)=crec(irec)
      return
      end

