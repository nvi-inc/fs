      subroutine snap_tpicd(lstring,iperiod)
      include 'hardware.ftni'
      character*(*) lstring
      integer iperiod
      character*20 ldum

      write(ldum,'("tpicd=",a,",",i10)') lstring,iperiod
      call squeezewrite(lufile,ldum)

      return
      end

