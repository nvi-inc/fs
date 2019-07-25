      subroutine ssrc(lname,ra,dec,epoch,jbuf,il,ierr)
C
      integer*2 jbuf(1),lname(5)
C
      icnext=1
C
      icnext=ichmv(jbuf,icnext,lname,1,10)
C
100   continue
      if (mod(icnext,2).eq.0) icnext=ichmv_ch(jbuf,icnext,' ')
      call scmd(jbuf,0,icnext/2,ierr)
C
      return
      end
