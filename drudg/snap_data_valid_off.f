      subroutine snap_data_valid_off()
      include 'hardware.ftni'

      if(krec_append) then
        write(luFile,"('data_valid',a1,'=off')") crec(irec)
      else
        write(luFile,"(a)") 'data_valid=off'
      endif
      return
      end
