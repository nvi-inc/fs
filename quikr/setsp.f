      subroutine setsp(idir,isp,ip)
C  set tape speed  c#870115:04:34# 
C 
      integer*2 ibuf(10)
      dimension ip(1)
C 
      ibuf(1) = 0 
      call char2hol('tp',ibuf(2),1,2)
      call mv2ma(ibuf(3),idir,isp,3h720)
      iclass = 0
      call put_buf(iclass,ibuf,-13,2hfs,0)
      call run_matcn(iclass,1) 
      call rmpar(ip)
      iclass = ip(1)
      call clrcl(iclass)
      ip(1) = 0 
      ip(2) = 0 
      return
      end 
