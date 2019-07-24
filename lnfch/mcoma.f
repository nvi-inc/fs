      function mcoma(ibuf,ich)

C     MOVE A COMMA INTO CHARACTER ICH OF IBUF 
C     RETURNS THE NEXT AVAILABLE CHARACTER (ICH+1)

      mcoma = ichmv(ibuf,ich,2H, ,1,1)

      return
      end 
