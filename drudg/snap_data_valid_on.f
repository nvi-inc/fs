      subroutine snap_data_valid_on()
      implicit none
      include 'hardware.ftni'

      if(krec_append) then
        write(luFile,"('data_valid',a1,'=on')") crec(irec)
      else
        write(luFile,"(a)") 'data_valid=on'
      endif
      return
      end
