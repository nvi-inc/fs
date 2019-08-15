      subroutine snap_systracks(lstring)
      include 'hardware.ftni'
      character*(*) lstring
      character*20 ldum
! 2015Jun05 JMG. Repalced squeezewrite by drudg_write. 
      if(krec_append) then
        write(ldum,'("systracks",a1,"=",a)') crec(irec),lstring
      else
        write(ldum,'("systracks",a,"=",a)') lstring
      endif
      call drudg_write(lufile,ldum)
      end

