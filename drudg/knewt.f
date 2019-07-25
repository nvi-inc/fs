	LOGICAL*4 FUNCTION KNEWT(IFT,IPAS,IPASP,IDIR,IDIRP,IFTOLD)
C KNEWT RETURNS TRUE IF THIS RUN WOULD START A NEW TAPE
C
      INCLUDE 'skparm.ftni'
      INCLUDE 'drcom.ftni'
C
C Input:
      integer ift,ipas,ipasp,idir,idirp,iftold

      KNEWT = IPAS.LT.IPASP.OR.
     .        (IPAS.EQ.IPASP.AND.IDIR.NE.IDIRP).OR.
     .        (IPAS.EQ.IPASP.AND.((IDIR.EQ.+1.AND.IFT.LT.IFTOLD)
     .        .OR.(IDIR.EQ.-1.AND.IFT.GT.IFTOLD)))
      IF (IPASP.LE.0) KNEWT=.TRUE.
C
      RETURN
      END
