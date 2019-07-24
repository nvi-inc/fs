      subroutine wait_relt(name,ip,ires,imul)
      implicit none
      character*(*) name
      integer*4 ip(5)
      integer ires,imul
c
      integer centisec
c
      if(ires.eq.1) then
       centisec=imul
      else if(ires.eq.2) then
       centisec=imul*100
      else if(ires.eq.3) then
       centisec=imul*60*100
      else if(ires.eq.4) then
       centisec=imul*60*60*100
      else if(ires.eq.5) then
       centisec=imul*24*60*60*100
      else
       centisec=0
      endif
      call fc_skd_wait(name,ip,centisec)
c
      return
      end
