      character*3 function lyes_no(kdum)

      logical kdum
      if(kdum) then
        lyes_no="YES"
      else
        lyes_no="NO"
      endif
      return
      end

