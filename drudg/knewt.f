	LOGICAL FUNCTION KNEWT(IFT,IPAS,IPASP,IDIR,IDIRP,IFTOLD)
C KNEWT RETURNS TRUE IF THIS RUN WOULD START A NEW TAPE
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
C
C 960819 nrv change final check for IPASP to .LT. 0 because 0 is
C            a valid S2 pass number

C Input:
      integer ift,ipas,ipasp,idir,idirp,iftold

      KNEWT = IPAS.LT.IPASP.OR.
     .        (IPAS.EQ.IPASP.AND.IDIR.NE.IDIRP).OR.
     .        (IPAS.EQ.IPASP.AND.((IDIR.EQ.+1.AND.IFT.LT.(IFTOLD-10))
     .        .OR.(IDIR.EQ.-1.AND.IFT.GT.(IFTOLD+10))))
      IF (IPASP.LT.0) KNEWT=.TRUE.
C
      RETURN
      END
