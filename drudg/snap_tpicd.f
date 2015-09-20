      subroutine snap_tpicd(lstring,iperiod)
      include 'hardware.ftni'
      character*(*) lstring
      integer iperiod
      character*20 ldum
! 2015Jun05 JMG. Repalced squeezewrite by drudg_write. 
      write(ldum,'("tpicd=",a,",",i10)') lstring,iperiod
      call drudg_write(lufile,ldum)

      return
      end

