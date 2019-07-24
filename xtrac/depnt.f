      subroutine depnt(jbuf,ifc,ilc,ipos,tim,pos,temp,n,ier,nd) 
C
      dimension tim(nd),pos(nd),temp(nd),ipos(nd) 
C
      integer*2 jbuf(1)
C 
      ifield=0
      iferr=1 
C 
C  INDEX NUMBER 
C 
      ipt=igtbn(jbuf,ifc,ilc,ifield,iferr)
C 
C  TIME SINCE MIDNIGHT
C 
      tima=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C  OFFSET 
C 
      posa=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C  TEMPERATURE
C 
      tempa=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C  CHECK FOR ERRORS 
C 
      if (iferr.gt.0) goto 100
      ier=ier+1 
      return
C 
100   continue
      n=n+1 
      if (n.gt.nd) return
      ipos(n)=ipt 
      tim(n)=tima 
      pos(n)=posa 
      temp(n)=tempa 
C 
      return
      end 
