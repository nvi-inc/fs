      subroutine get_att(iat1,iat2,ip)
      integer iat1,iat2
      integer*4 ip(5)
c
      integer*2 itp(10)                     ! buffer for ! data with tp
      integer*2 ibuf(10)                     ! buffer for % date with at
      dimension ireg(2)                     ! registers from exec calls
      integer get_buf
      equivalence (reg,ireg(1)) 
c
      call char2hol('if',ibuf(2),1,2)
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
      call ma2if(ibuf,itp,iat1,iat2,in1,in2,tp1ifd,tp2ifd,iremif)
c
      return
      end


