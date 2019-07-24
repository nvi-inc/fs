      subroutine lvdof(ip)

C  lvdt oscilator off 
C 
      dimension ip(5)
      integer*2 ibuf(12)
C 
      include '../include/fscom.i'
C 
      nrec = 0
      iclass = 0
      ibuf(1) = 0 
      call char2hol('hd',ibuf(2),1,2)
      call ichmv(ibuf,5,8H00010000,1,8) 
      call put_buf(iclass,ibuf,-12,2hfs,0)  
      nrec = nrec+1 
C 
C   SEND STROBE 
C 
      ibuf(1)=5 
      call char2hol('% ',ibuf(2),1,2)
      call put_buf(iclass,ibuf,-3,2hfs,0) 
      nrec=nrec+1 
C 
C  2. Now schedule MATCN
C 
      call run_matcn(iclass,nrec)
      call rmpar(ip)
      call clrcl(ip(1)) 
C 
      return
      end 
