      subroutine delne(jbuf,ifc,ilc,lsorna,ra,dec,epoch,lcpre,iwpre,
     +                 iwfiv,iwonof,iwpeak,lcpos,iwpos,mc,mprc,iferr)
C
      integer*2 jbuf(1),lsorna(mc),lcpre(mprc),lcpos(mprc)
C
      iferr=1
      ifield=0
C
C SOURCE NAME
C
      call gtchr(lsorna,1,mc*2,jbuf,ifc,ilc,ifield,iferr)
      call lower(lsorna,mc*2)
C
C  RA
C
      ra=gtra(jbuf,ifc,ilc,ifield,iferr)
C
C DEC
C
      dec=gtdc(jbuf,ifc,ilc,ifield,iferr)
C
C  EPOCH
C
      epoch=gtrel(jbuf,ifc,ilc,ifield,iferr)
C
C  PRE OB PROCEDURE
C
      call gtchr(lcpre,1,mprc*2,jbuf,ifc,ilc,ifield,iferr)
C
C  PRE OB WAIT
C
      iwpre=igtbn(jbuf,ifc,ilc,ifield,iferr)
C
C FIVEPT POINT WAIT
C
      iwfiv=igtbn(jbuf,ifc,ilc,ifield,iferr)
C
C ONOFF WAIT
C
      iwonof=igtbn(jbuf,ifc,ilc,ifield,iferr)
C
C PEAKF WAIT
C
      iwpeak=igtbn(jbuf,ifc,ilc,ifield,iferr)
C
C  POST OB PROCEDURE
C
      call gtchr(lcpos,1,mprc*2,jbuf,ifc,ilc,ifield,iferr)
C
C  POST OB WAIT
C
      iwpos=igtbn(jbuf,ifc,ilc,ifield,iferr)
C
      return
      end
