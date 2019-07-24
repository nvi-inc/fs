      subroutine hmove(ihd,ihspd,idirct,idur,ip)
C  move head block .c#870115:04:55# 
C 
C HMOVE schedules MATCN to actually move the head block 
C 
C  INPUT VARIABLES: 
      dimension ip(1) 
C     IHD - head to be moved (1 or 2) 
C     IHSPD - speed (0=slow; 1=fast)
C     IDIRCT - direction of movement (0=reverse; 1=forward) 
C     IDUR - duration of movement (# of 40 usec increments) 
C 
C 
C  LOCAL VARIABLES: 
      integer*2 ibuf(20)
      dimension jdur(2)
C 
C  INITIALIZED VARIABLES: 
C 
      data ilen /40/
C 
C 
C 
      ibuf(1) = 0 
      call char2hol('hd',ibuf(2),1,2)
      idumm1 = ichmv(ibuf,5, 8h00000000,1, 8) 
      idumm1 = ib2as(ihspd,ibuf,6,1)
      idumm1 = ib2as(idirct,ibuf,7,1) 
      idumm1 = ib2as(ihd-1,ibuf,8,1)
cxx      call hex(idur,jdur,1) 
      idumm1 = ichmv(ibuf,9,jdur,1,4) 
      iclass = 0
      call put_buf(iclass,ibuf,-12,2hfs,0)
      nrec = 1
      ibuf(1)=5 
      call char2hol('( ',ibuf(2),1,2)
      call put_buf(iclass,ibuf,-3 ,2hfs,0)
      nrec=2
      call run_matcn(iclass,nrec)
      call rmpar(ip)
      call clrcl(ip(1)) 
      return
      end 
