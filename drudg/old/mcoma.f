C@MCOMA
      integer FUNCTION MCOMA(IBUF,ICH)
C     MOVE A COMMA INTO CHARACTER ICH OF IBUF
C     RETURNS THE NEXT AVAILABLE CHARACTER (ICH+1)
      integer*2 ibuf(*)
      integer ich
      MCOMA = ichmv_ch(IBUF,ICH,',')
      RETURN
      END

