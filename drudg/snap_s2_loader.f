      subroutine snap_s2_loader()
      include 'hardware.ftni'
      if(krec_append) then
         write(luFile,"('loader',a1)") crec(irec)
      else
         write(luFile,"('loader')")
      endif
      return
      end


