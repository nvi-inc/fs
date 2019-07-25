      function mcoma(ibuf,ich)

C     MOVE A COMMA INTO CHARACTER ICH OF IBUF 
C     RETURNS THE NEXT AVAILABLE CHARACTER (ICH+1)

      mcoma = ichmv_ch(ibuf,ich,',')

      return
      end 
