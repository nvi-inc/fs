	LOGICAL FUNCTION KNEWT(IFT,IPAS,IPASP,IDIR,IDIRP,IFTOLD)
C KNEWT RETURNS TRUE IF THIS RUN WOULD START A NEW TAPE
C
      include '../skdrincl/skparm.ftni'
C
C 960819 nrv change final check for IPASP to .LT. 0 because 0 is
C            a valid S2 pass number
C 000107 nrv Allow a 100-ft difference before declaring a new tape.
C 2003July08 JMGipson. changed to 150

C Input:
      integer ift,ipas,ipasp,idir,idirp,iftold
      integer ift_tol
      parameter (ift_tol=150)

      KNEWT =
     >   IPAS.LT.IPASP.OR.
     .  (IPAS.EQ.IPASP.AND.IDIR.NE.IDIRP).OR.
     .  (IPAS.EQ.IPASP.AND.((IDIR.EQ.+1.AND.IFT.LT.(IFTOLD-ift_tol))
     .   .OR.(IDIR.EQ.-1.AND.IFT.GT.(IFTOLD+ift_tol))))
      IF (IPASP.LT.0) KNEWT=.TRUE.
C
      RETURN
      END
