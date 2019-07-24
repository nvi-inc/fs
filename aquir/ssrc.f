      subroutine ssrc(lname,ra,dec,epoch,jbuf,il,ierr)
C
      integer*2 jbuf(1),lname(5)
      double precision dra,ddec
C
      icnext=1
C
      icnext=ichmv(jbuf,icnext,lname,1,10)
C
100   continue
      if (mod(icnext,2).eq.0) icnext=ichmv(jbuf,icnext,2H  ,1,1)
      call scmd(jbuf,0,icnext/2,ierr)
C
      return
      end
