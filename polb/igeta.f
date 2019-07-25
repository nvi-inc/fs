      subroutine igeta(ib,ifc,ilc,ic1,ic2,kerr)

      logical kerr
C
      kerr=.true.
      ic2=0
      ic1=0
      if (ifc.gt.ilc) return 
      ic2=iscn_ch(ib,ifc,ilc,',')
      if (ic2.le.0) goto 20 
      if (ic2.gt.ifc) goto 10 
C 
      ifc=ifc+1 
      ic2=0 
      return
C 
10    continue
      ic1=ifc 
      ifc=ic2+1
      ic2=ic2-1
      kerr=.false.
      return
C
20    continue
      il=iflch(ib,ilc)
      if (il.lt.ifc) return
      ic2=il
      ic1=ifc
      ifc=ilc+1
      kerr=.false.

      return
      end
