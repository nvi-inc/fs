      subroutine snap_prepass()
      include 'hardware.ftni'

      if(MaxTapLen .gt. 17000) then
         if(krec_append) then
            write(luFile,'("prepassthin",a1)') crec(irec)
         else
            write(luFile,'("prepassthin")')
         endif
      else
         if(krec_append) then
            write(luFile,'("prepass",a1)') crec(irec)
         else
            write(luFile,'("prepass")')
         endif
      endif
      end

