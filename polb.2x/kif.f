      logical function kif(imess,len,ib,ic1,ic2,kerr,lu)

      logical kerr
      integer*2 ib(1),imess(1),id,len
C
      kif=kerr
      if (.not.kerr) return
      if (len.le.0) goto 1
      nchar=len
      call po_put_i(imess,nchar)
C 
1     continue
      if (ic1.le.0.or.ic2.lt.ic1) return 
      ist=ic1 
      ilen=ic2-ic1+1
      if(mod(ic1,2).eq.1) goto 10
      call ichmv(id,1,ib,ic1,1) 
      call ichmv_ch(id,2,'_')
      call po_put_i(id,min0(ilen,2))
      ist=ist+1
      ilen=ilen-1
      if (ilen.le.0) return
C
10    continue
      call po_put_i(ib((ist+1)/2),ilen)

      return
      end
