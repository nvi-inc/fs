      subroutine snap_systracks(lstring)
      include 'hardware.ftni'
      character*(*) lstring
      character*20 ldum

      if(krec_append) then
        write(ldum,'("systracks",a1,"=",a)') crec(irec),lstring
      else
        write(ldum,'("systracks",a,"=",a)') lstring
      endif
      call squeezewrite(lufile,ldum)
      end

