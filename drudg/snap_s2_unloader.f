      subroutine snap_s2_unloader()
      include 'hardware.ftni'
      if(krec_append) then
         write(luFile,"('unloader',a1)") crec(irec)
      else
         write(luFile,"('unloader')")
      endif
      return
      end


