      subroutine susp(ires,imul)
      implicit none
      integer ires,imul
c
      integer centisec,fc_rte_sleep,idum
c
      if(ires.le.0) then
        return
      else if(ires.eq.1) then
        centisec=imul
      else if(ires.eq.2) then
        centisec=imul*100
      else if(ires.eq.3) then
        centisec=imul*60*100
      else if(ires.eq.4) then
        centisec=imul*60*60*100
      else if(ires.eq.5) then
        centisec=imul*24*60*60*100
      else if(ires.ge.6) then
        return
      endif
c
      idum=fc_rte_sleep( centisec)
      return
      end
