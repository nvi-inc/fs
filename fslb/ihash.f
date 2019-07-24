      integer*2 function ihash(ias,ifc,nchar) 
      integer*2 ias(1)
      integer*2 mask,istate
      integer n,ifb,nb
      data n/16/,mask/o'040003'/
c
      istate = 0
      ifb=1+(ifc-1)*8
      nb=nchar*8
      zero=0
      call crcc(n,mask,istate,ias,ifb,nb,ias,zero)
      ihash = istate

      return
      end 
