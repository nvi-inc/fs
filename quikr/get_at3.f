      subroutine get_at3(iat3,ip)
      integer iat3
      integer*4 ip(5)
c
      integer isw(4)
      integer*2 itp(10)                     ! buffer for ! data with tp
      integer*2 ibuf(10)                     ! buffer for % date with at
      dimension ireg(2)                     ! registers from exec calls
      integer get_buf
      equivalence (reg,ireg(1)) 
c
      call char2hol('i3',ibuf(2),1,2)
      iclass = 0
      ibuf(1) = -2
      call put_buf(iclass,ibuf,-4,'fs','  ')
C 
      nrec = 1
      call run_matcn(iclass,nrec)
      call rmpar(ip)
      if(ip(3).lt.0) return
      iclass=ip(1)
c
      ireg(2) = get_buf(iclass,ibuf,-10,idum,idum)
      call ma2i3(itp,ibuf,iat3,imix,isw(1),isw(2),isw(3),isw(4),
     &     ipcalp,iswp,freq,irem,ipcal,ilo,tpi)
c
      return
      end


