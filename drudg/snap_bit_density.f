      subroutine snap_bit_density(ibit)
      include 'hardware.ftni'
      integer ibit

      if(krec_append) then
        write(luFile,'("bit_density",a1,"=",i5)') crec(irec),ibit
      else
        write(luFile,'("bit_density=",i5)') ibit
      endif

      end

